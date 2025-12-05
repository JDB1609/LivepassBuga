<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="dao.EventDAO,utils.Event" %>
<%
  String role = (String) session.getAttribute("role");
  Integer uid = (Integer) session.getAttribute("userId");
  if (uid == null || role == null || !"ORGANIZADOR".equalsIgnoreCase(role)) {
    response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp");
    return;
  }

  String q = request.getParameter("q");
  String status = request.getParameter("status");
  try {
    EventDAO dao = new EventDAO();
    List<Event> events = dao.listByOrganizer(uid, q, status);
    request.setAttribute("events", events);
    request.setAttribute("f_q", q);
    request.setAttribute("f_status", status);
  } catch (Exception ex) {
    request.setAttribute("events", java.util.Collections.emptyList());
    request.setAttribute("f_q", q);
    request.setAttribute("f_status", status);
  }
%>
