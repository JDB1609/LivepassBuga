<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.EventDAO, utils.Event, utils.Conexion" %>
<%@ page import="java.sql.*, java.math.BigDecimal" %>

<%!
  static final String DEFAULT_BACK_PAGE = "/Vista/PagoSimulado.jsp";

  String back(HttpServletRequest req, int eventId, int qty, String msg) {
    String backPage = req.getParameter("back");
    if (backPage == null || backPage.trim().isEmpty()) backPage = DEFAULT_BACK_PAGE;
    try {
      return req.getContextPath() + backPage
           + "?eventId=" + eventId
           + "&qty=" + qty
           + (msg != null ? ("&err=" + java.net.URLEncoder.encode(msg, "UTF-8")) : "");
    } catch (Exception e) {
      return req.getContextPath() + backPage + "?eventId=" + eventId + "&qty=" + qty;
    }
  }

  boolean luhn(String digits) {
    int sum = 0; boolean alt = false;
    for (int i = digits.length()-1; i>=0; i--) {
      int n = digits.charAt(i) - '0';
      if (alt) { n *= 2; if (n > 9) n -= 9; }
      sum += n; alt = !alt;
    }
    return sum % 10 == 0;
  }
%>

<%
  request.setCharacterEncoding("UTF-8");
  final String ctx = request.getContextPath();
  String redirect = null;

  // --- Guard de sesión ---
  Integer uid = (Integer) session.getAttribute("userId");
  if (uid == null) { response.sendRedirect(ctx + "/Vista/Login.jsp"); return; }

  // --- Parámetros básicos ---
  int eventId = 0, qty = 1;
  String method = request.getParameter("paymentMethod");
  if (method == null) method = "CARD";
  method = method.toUpperCase();

  try { eventId = Integer.parseInt(request.getParameter("eventId")); } catch (Exception ignore) {}
  try { qty     = Math.max(1, Integer.parseInt(request.getParameter("qty"))); } catch (Exception ignore) {}
  if (eventId <= 0) { response.sendRedirect(ctx + "/Vista/PaginaPrincipal.jsp"); return; }

  // --- Evento / precios ---
  Event ev = new EventDAO().findById(eventId).orElse(null);
  if (ev == null) { response.sendRedirect(ctx + "/Vista/PaginaPrincipal.jsp"); return; }

  BigDecimal unit = (ev.getPriceValue()!=null ? ev.getPriceValue() : BigDecimal.ZERO);
  BigDecimal expected = unit.multiply(BigDecimal.valueOf(qty));
  BigDecimal amount = null;
  try { amount = new BigDecimal(String.valueOf(request.getParameter("amount"))); } catch (Exception ignore) {}
  if (amount == null || expected.compareTo(amount) != 0) {
    response.sendRedirect(back(request, eventId, qty, "Monto inválido.")); return;
  }

  // --- Validaciones por método ---
  if ("VISA".equals(method) || "MASTERCARD".equals(method) || "CARD".equals(method)) {
    String holder = request.getParameter("holder");
    String card   = request.getParameter("card");
    String cvv    = request.getParameter("cvv");
    String exp    = request.getParameter("exp"); // MM/AA
    if (holder == null || holder.trim().isEmpty()) {
      response.sendRedirect(back(request, eventId, qty, "Ingresa el titular de la tarjeta.")); return;
    }
    String digits = (card==null ? "" : card.replaceAll("\\D",""));
    if (digits.length() < 13 || digits.length() > 19 || !luhn(digits)) {
      response.sendRedirect(back(request, eventId, qty, "Número de tarjeta inválido.")); return;
    }
    if (digits.endsWith("0000")) { // regla demo
      response.sendRedirect(back(request, eventId, qty, "Transacción rechazada por el banco.")); return;
    }
    if (cvv == null || !cvv.matches("\\d{3,4}")) {
      response.sendRedirect(back(request, eventId, qty, "CVV inválido.")); return;
    }
    if (exp == null || !exp.matches("(?:0[1-9]|1[0-2])\\/\\d{2}")) {
      response.sendRedirect(back(request, eventId, qty, "Vencimiento inválido (usa MM/AA).")); return;
    } else {
      try {
        String[] pa = exp.split("/");
        java.time.YearMonth ym = java.time.YearMonth.of(2000+Integer.parseInt(pa[1]), Integer.parseInt(pa[0]));
        if (ym.isBefore(java.time.YearMonth.now())) {
          response.sendRedirect(back(request, eventId, qty, "La tarjeta está vencida.")); return;
        }
      } catch (Exception e) {
        response.sendRedirect(back(request, eventId, qty, "Vencimiento inválido.")); return;
      }
    }
  } else if ("PSE".equals(method)) {
    String approved = request.getParameter("approved"); // yes/no del simulador
    String bank     = request.getParameter("bank");
    if (bank == null || bank.trim().isEmpty()) {
      response.sendRedirect(back(request, eventId, qty, "Selecciona tu banco en PSE.")); return;
    }
    if (!"yes".equalsIgnoreCase(approved)) {
      response.sendRedirect(back(request, eventId, qty, "Operación cancelada por el usuario (PSE).")); return;
    }
  } else if ("NEQUI".equals(method)) {
    String approved = request.getParameter("approved");
    String phone    = request.getParameter("phone");
    String otp      = request.getParameter("otp");
    if (phone == null || phone.trim().isEmpty() || otp == null || otp.trim().isEmpty()) {
      response.sendRedirect(back(request, eventId, qty, "Completa teléfono y código en Nequi.")); return;
    }
    if (!"yes".equalsIgnoreCase(approved)) {
      response.sendRedirect(back(request, eventId, qty, "Operación cancelada por el usuario (Nequi).")); return;
    }
  } else {
    response.sendRedirect(back(request, eventId, qty, "Método de pago no soportado.")); return;
  }

  // --- Cupos previos ---
  if (qty > ev.getAvailability()) {
    response.sendRedirect(back(request, eventId, qty, "No hay cupos suficientes.")); return;
  }

  // --- Simulación de aprobación + persistencia ---
  String ref = "SIM-" + (System.currentTimeMillis()%100000) + "-" + (100 + (int)(Math.random()*900));
  String doc = request.getParameter("doc"); if (doc == null) doc = "";
  String qrPayload = "LP|" + ref + "|" + uid + "|" + eventId + "|" + System.currentTimeMillis();

  Conexion cx = new Conexion();
  Connection cn = null;
  try {
    cn = cx.getConnection();
    cn.setAutoCommit(false);

    // 1) Confirmar cupos atómicamente
    try (PreparedStatement up = cn.prepareStatement(
          "UPDATE events SET sold = sold + ? WHERE id = ? AND (capacity - sold) >= ?")) {
      up.setInt(1, qty);
      up.setInt(2, eventId);
      up.setInt(3, qty);
      int n = up.executeUpdate();
      if (n == 0) throw new SQLException("Sin cupos al confirmar.");
    }

    // 2) Registrar ticket (AJUSTADO A TU ESQUEMA)
    try (PreparedStatement ins = cn.prepareStatement(
          "INSERT INTO tickets(user_id,event_id,qty,unit_price,total_price,purchase_at,payment_ref,doc,qr_data,status) " +
          "VALUES (?,?,?,?,?,NOW(),?,?,?,?)")) {
      ins.setInt(1, uid);
      ins.setInt(2, eventId);
      ins.setInt(3, qty);
      ins.setBigDecimal(4, unit);
      ins.setBigDecimal(5, expected);
      ins.setString(6, ref);
      ins.setString(7, doc);
      ins.setString(8, qrPayload);
      ins.setString(9, "ACTIVO");
      int n = ins.executeUpdate();
      if (n == 0) throw new SQLException("No se insertó ticket");
    }

    cn.commit();

    // Éxito → MisTickets
    redirect = ctx + "/Vista/MisTickets.jsp?ok=1&ref=" + java.net.URLEncoder.encode(ref, "UTF-8");

  } catch (Exception ex) {
    try { if (cn != null) cn.rollback(); } catch (Exception ignore) {}
    ex.printStackTrace();
    redirect = back(request, eventId, qty, "No pudimos procesar el pago. Intenta nuevamente.");
  } finally {
    try { if (cn != null) { cn.setAutoCommit(true); cn.close(); } } catch (Exception ignore) {}
    cx.cerrarConexion();
  }

  if (redirect == null) redirect = ctx + "/Vista/PaginaPrincipal.jsp";
  response.sendRedirect(redirect);
%>
