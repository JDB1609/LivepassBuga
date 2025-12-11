<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.EventDAO, utils.Event, utils.Conexion, dao.TicketDAO, dao.ReminderDAO" %>
<%@ page import="java.sql.*, java.math.BigDecimal" %>

<%!
  static final String DEFAULT_BACK_PAGE = "/Vista/PagoSimulado.jsp";

  /** Construye la URL de regreso completamente limpia */
  String back(HttpServletRequest req, int eventId, int qty, String msg) {

    String backPage = req.getParameter("back");

    // --- LIMPIAR ESPACIOS SIEMPRE ---
    if (backPage == null) {
      backPage = DEFAULT_BACK_PAGE;
    } else {
      backPage = backPage.trim();   // ← AQUÍ SE ARREGLA EL 404
      if (backPage.isEmpty()) backPage = DEFAULT_BACK_PAGE;
    }

    // Armar URL
    StringBuilder sb = new StringBuilder();
    sb.append(req.getContextPath()).append(backPage)
      .append("?eventId=").append(eventId)
      .append("&qty=").append(qty);

    String tt = req.getParameter("ticketTypeId");
    if (tt != null && !tt.trim().isEmpty()) {
        sb.append("&ticketTypeId=").append(tt.trim());
    }

    if (msg != null) {
      try {
        sb.append("&err=").append(java.net.URLEncoder.encode(msg, "UTF-8"));
      } catch (Exception ignore) {}
    }

    return sb.toString();
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

  // ===========================
  // GUARD SESSION
  // ===========================
  Integer uid = (Integer) session.getAttribute("userId");
  if (uid == null) { response.sendRedirect(ctx + "/Vista/Login.jsp"); return; }

  // ===========================
  // PARAMETROS
  // ===========================
  int eventId = 0, qty = 1, ticketTypeId = 0;
  String method = request.getParameter("paymentMethod");

  if (method == null) method = "CARD";
  method = method.toUpperCase();

  try { eventId      = Integer.parseInt(request.getParameter("eventId")); }      catch (Exception ignore) {}
  try { qty          = Math.max(1, Integer.parseInt(request.getParameter("qty"))); } catch (Exception ignore) {}
  try { ticketTypeId = Integer.parseInt(request.getParameter("ticketTypeId")); } catch (Exception ignore) {}

  if (eventId <= 0) { response.sendRedirect(ctx + "/Vista/PaginaPrincipal.jsp"); return; }

  // ===========================
  // CARGAR EVENTO
  // ===========================
  Event ev = new EventDAO().findById(eventId).orElse(null);
  if (ev == null) { response.sendRedirect(ctx + "/Vista/PaginaPrincipal.jsp"); return; }

  // ===========================
  // PRECIO DEL TIPO DE TICKET
  // ===========================
  BigDecimal unit = BigDecimal.ZERO;

  try {
    Conexion cxTmp = new Conexion();
    String sql;

    if (ticketTypeId > 0) {
      sql = "SELECT id, price FROM ticket_types WHERE id = ? AND id_event = ? LIMIT 1";
    } else {
      sql = "SELECT id, price FROM ticket_types WHERE id_event = ? ORDER BY price ASC LIMIT 1";
    }

    try (Connection cn = cxTmp.getConnection();
         PreparedStatement ps = cn.prepareStatement(sql)) {

      if (ticketTypeId > 0) {
        ps.setInt(1, ticketTypeId);
        ps.setInt(2, eventId);
      } else {
        ps.setInt(1, eventId);
      }

      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
          ticketTypeId = rs.getInt("id");
          unit         = rs.getBigDecimal("price");
        }
      }
    }
    cxTmp.cerrarConexion();
  } catch (Exception e) {
    e.printStackTrace();
  }

  // Fallback si NO hay ticket_types
  if (unit == null || unit.compareTo(BigDecimal.ZERO) <= 0) {
    unit = (ev.getPriceValue() != null ? ev.getPriceValue() : BigDecimal.ZERO);
  }

  BigDecimal expected = unit.multiply(BigDecimal.valueOf(qty));

  // MONTO enviado desde el formulario
  BigDecimal amount = null;
  try {
    String amountStr = request.getParameter("amount");
    if (amountStr != null) {
      amount = new BigDecimal(amountStr.trim());
    }
  } catch (Exception ignore) {}

  if (amount == null || expected.compareTo(amount) != 0) {
    response.sendRedirect(back(request, eventId, qty, "Monto inválido.")); return;
  }

  // ===========================
  // VALIDAR MÉTODOS DE PAGO
  // ===========================
  if ("VISA".equals(method) || "MASTERCARD".equals(method) || "CARD".equals(method)) {

    String holder = request.getParameter("holder");
    String card   = request.getParameter("card");
    String cvv    = request.getParameter("cvv");
    String exp    = request.getParameter("exp");

    if (holder == null || holder.trim().isEmpty())
      { response.sendRedirect(back(request, eventId, qty, "Ingresa el titular de la tarjeta.")); return; }

    String digits = (card==null ? "" : card.replaceAll("\\D",""));
    if (digits.length()<13 || digits.length()>19 || !luhn(digits))
      { response.sendRedirect(back(request, eventId, qty, "Número de tarjeta inválido.")); return; }

    if (digits.endsWith("0000"))
      { response.sendRedirect(back(request, eventId, qty, "Transacción rechazada por el banco.")); return; }

    if (cvv == null || !cvv.matches("\\d{3,4}"))
      { response.sendRedirect(back(request, eventId, qty, "CVV inválido.")); return; }

    if (exp == null || !exp.matches("(?:0[1-9]|1[0-2])\\/\\d{2}"))
      { response.sendRedirect(back(request, eventId, qty, "Vencimiento inválido.")); return; }

  } else if ("PSE".equals(method)) {

    if (request.getParameter("bank") == null)
      { response.sendRedirect(back(request, eventId, qty, "Selecciona tu banco en PSE.")); return; }

    if (!"yes".equalsIgnoreCase(request.getParameter("approved")))
      { response.sendRedirect(back(request, eventId, qty, "Operación cancelada por el usuario (PSE).")); return; }

  } else if ("NEQUI".equals(method)) {

    if (request.getParameter("phone") == null ||
        request.getParameter("otp") == null)
      { response.sendRedirect(back(request, eventId, qty, "Completa teléfono y código.")); return; }

    if (!"yes".equalsIgnoreCase(request.getParameter("approved")))
      { response.sendRedirect(back(request, eventId, qty, "Operación cancelada por el usuario (Nequi).")); return; }
  }

  // ===========================
  // VALIDAR CUPOS
  // ===========================
  if (qty > ev.getAvailability()) {
    response.sendRedirect(back(request, eventId, qty, "No hay cupos suficientes.")); return;
  }

  // ===========================
  // CREAR TICKET
  // ===========================
  TicketDAO tdao = new TicketDAO();
  TicketDAO.PurchaseResult pr = tdao.purchase(eventId, uid, qty, unit, ticketTypeId);

  if (!pr.ok) {
    response.sendRedirect(back(request, eventId, qty, "No se pudo registrar el ticket.")); return;
  }

  // ===========================
  // REGISTRAR PAYMENT
  // ===========================
  String ref = "SIM-" + (System.currentTimeMillis()%100000) + "-" + (100+(int)(Math.random()*900));

  Conexion cx = new Conexion();
  Connection cn = null;

  try {
    cn = cx.getConnection();

    try (PreparedStatement ps = cn.prepareStatement(
      "INSERT INTO payments(id_card,id_event,price,pay_method,status) VALUES (?,?,?,?,?)"
    )) {
      ps.setInt(1, uid);
      ps.setInt(2, eventId);
      ps.setBigDecimal(3, expected);
      ps.setString(4, method);
      ps.setString(5, "Aprobado");
      ps.executeUpdate();
    }
    
    // Obtener el email del usuario desde sesión
    String userEmail = (String) session.getAttribute("userEmail");

    // Crear recordatorio automático
    dao.ReminderDAO reminderDAO = new dao.ReminderDAO();
    reminderDAO.crearRecordatorioCompra(userEmail, eventId);

    redirect = ctx + "/Vista/MisTickets.jsp?ok=1&ref=" +
               java.net.URLEncoder.encode(ref, "UTF-8");

  } catch (Exception ex) {
    ex.printStackTrace();
    redirect = back(request, eventId, qty, "No pudimos registrar el pago.");
  } finally {
    try { if (cn != null) cn.close(); } catch (Exception ignore) {}
    cx.cerrarConexion();
  }

  response.sendRedirect(redirect);
%>
