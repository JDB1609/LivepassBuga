<%@ page import="dao.EventDAO, java.util.List, utils.Event" %>
<%
  try {
    EventDAO dao = new EventDAO();
    List<Event> featured = dao.listFeatured(6); // 6 tarjetas
    request.setAttribute("featured", featured);
  } catch (Exception ex) {
    request.setAttribute("home_error", ex.getMessage());
  }
%>
