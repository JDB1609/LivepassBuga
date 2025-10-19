<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="dao.EventDAO, dao.TicketDAO, utils.Event" %>

<%
  request.setCharacterEncoding("UTF-8");

  Integer uid = (Integer) session.getAttribute("userId");
  if (uid == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }

  int eventId = 0, qty = 1;
  try { eventId = Integer.parseInt(request.getParameter("eventId")); } catch(Exception ignore){}
  try { qty = Math.max(1, Integer.parseInt(request.getParameter("qty"))); } catch(Exception ignore){}

  String tokenForm = request.getParameter("payToken");
  String tokenSess = (String) session.getAttribute("payToken");
  session.removeAttribute("payToken"); // úsalo una vez
  if (tokenSess == null || !tokenSess.equals(tokenForm)) {
    response.sendRedirect(request.getContextPath()+"/Vista/PagoError.jsp?reason=token");
    return;
  }

  Event ev = new EventDAO().findById(eventId).orElse(null);
  if (ev == null) { response.sendRedirect(request.getContextPath()+"/Vista/PaginaPrincipal.jsp"); return; }

  // --- "Autorización" simulada ---
  String card = (request.getParameter("card")!=null) ? request.getParameter("card").replaceAll("\\s+","") : "";
  boolean authorized = (card.length() >= 12) && !card.endsWith("0000");

  if (!authorized) {
    response.sendRedirect(request.getContextPath()+"/Vista/PagoError.jsp?reason=card");
    return;
  }

  // --- Ejecutar compra ---
  BigDecimal unit = ev.getPriceValue() != null ? ev.getPriceValue() : BigDecimal.ZERO;
  dao.TicketDAO.PurchaseResult pr = new TicketDAO().purchase(eventId, uid, qty, unit);

  if (pr.ok) {
    // Guardamos códigos en sesión para mostrarlos en OK (y los retiramos al verlos)
    session.setAttribute("lastCodes", pr.codes);
    response.sendRedirect(request.getContextPath()+"/Vista/PagoOK.jsp?eventId="+eventId+"&qty="+qty);
  } else {
    response.sendRedirect(request.getContextPath()+"/Vista/PagoError.jsp?reason=db");
  }
%>

