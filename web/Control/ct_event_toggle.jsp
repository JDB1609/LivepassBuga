<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.EventDAO" %>
<%
  String role = (String) session.getAttribute("role");
  Integer uid = (Integer) session.getAttribute("userId");
  if (uid == null || role == null || !"ORGANIZADOR".equalsIgnoreCase(role)) {
    response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp");
    return;
  }

  String idStr = request.getParameter("id");
  String to    = request.getParameter("to"); // PUBLICADO | BORRADOR | FINALIZADO
  try {
    int id = Integer.parseInt(idStr);
    dao.EventDAO dao = new EventDAO();
    dao.toggleStatus(id, uid, to);
    response.sendRedirect(request.getContextPath()+"/Vista/EventosOrganizador.jsp?ok=1");
  } catch (Exception ex) {
    response.sendRedirect(request.getContextPath()+"/Vista/EventosOrganizador.jsp?ok=0");
  }
%>
