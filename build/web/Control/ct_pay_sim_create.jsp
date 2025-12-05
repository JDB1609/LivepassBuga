<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.EventDAO,dao.OrderDAO,utils.Event,java.math.BigDecimal,java.net.URLEncoder" %>
<%
  Integer uid = (Integer) session.getAttribute("userId");
  if (uid == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }

  int eventId = Integer.parseInt(request.getParameter("eventId"));
  int qty = Integer.parseInt(request.getParameter("qty"));
  qty = Math.max(1, Math.min(qty, 10));

  Event ev = new EventDAO().findById(eventId).orElse(null);
  if (ev == null) { response.sendRedirect(request.getContextPath()+"/Vista/PaginaPrincipal.jsp"); return; }

  BigDecimal unit  = ev.getPrice();
  BigDecimal total = unit.multiply(new BigDecimal(qty));

  OrderDAO od = new OrderDAO();
  int orderId = od.createPendingOrder(uid, eventId, qty, unit, total);
  od.attachProvider(orderId, "SIM", "SIM-PREF-"+System.currentTimeMillis());

  String base = request.getContextPath();
  String returnUrl = base + "/Vista/PayReturn.jsp?orderId=" + orderId;
  String gateway = base + "/Vista/FakeGateway.jsp?orderId="+orderId
                 + "&amount=" + URLEncoder.encode(total.toPlainString(),"UTF-8")
                 + "&return=" + URLEncoder.encode(returnUrl,"UTF-8");
  response.sendRedirect(gateway);
%>
