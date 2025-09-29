<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="dao.EventDAO, utils.Event" %>
<%
  // Guard de sesión/rol
  Integer uid = (Integer) session.getAttribute("userId");
  if (uid == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }
  String role = (String) session.getAttribute("role");
  if (role == null || !"ORGANIZADOR".equalsIgnoreCase(role)) {
    response.sendRedirect(request.getContextPath()+"/Vista/HomeCliente.jsp"); return;
  }

  // Filtros que llegan del formulario de la vista
  String q      = request.getParameter("q");
  String status = request.getParameter("status");

  // Consulta DAO
  EventDAO dao = new EventDAO();
  List<Event> events = dao.listByOrganizer(uid, q, status);

  // Atributos para la vista
  request.setAttribute("events", events);
  request.setAttribute("f_q", q);
  request.setAttribute("f_status", status);
%>
