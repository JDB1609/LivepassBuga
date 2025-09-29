<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="dao.TicketDAO, utils.Ticket" %>
<%
  Integer uid = (Integer) session.getAttribute("userId");
  if (uid == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }

  TicketDAO tdao = new TicketDAO();
  List<Ticket> upcoming = tdao.listUpcomingByUser(uid); // futuros, ACTIVO
  List<Ticket> past     = tdao.listPastByUser(uid);     // eventos pasados (USADO/REEMBOLSADO/ACTIVO si ya pasó)

  request.setAttribute("upcoming", upcoming);
  request.setAttribute("past", past);
%>
