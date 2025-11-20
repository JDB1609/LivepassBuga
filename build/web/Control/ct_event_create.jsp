<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="utils.Event, dao.EventDAO" %>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%@ page import="java.math.BigDecimal" %>
<%
  Integer uid = (Integer) session.getAttribute("userId");
  String role = (String) session.getAttribute("role");
  if (uid == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }
  if (role == null || !"ORGANIZADOR".equalsIgnoreCase(role)) {
    response.sendRedirect(request.getContextPath()+"/Vista/HomeCliente.jsp"); return;
  }

  request.setCharacterEncoding("UTF-8");

  String title   = request.getParameter("title");
  String venue   = request.getParameter("venue");
  String city    = request.getParameter("city");
  String genre   = request.getParameter("genre");
  String dtStr   = request.getParameter("date_time");
  String capStr  = request.getParameter("capacity");
  String priceStr= request.getParameter("price");
  String status  = request.getParameter("status");
  String description = request.getParameter("description");
  String image = request.getParameter("image");
  

  try {
    Event e = new Event();
    e.setOrganizerId(uid);
    e.setTitle(title);
    e.setVenue(venue);
    e.setCity(city);
    e.setGenre(genre);
    e.setDescription(description);
    e.setImage(image);
    java.time.LocalDateTime dt = LocalDateTime.parse(dtStr);
    e.setDateTime(dt);
    e.setCapacity(Integer.parseInt(capStr));
    e.setSold(0);
    e.setStatus(status);
    // precio normalizado
    String s = priceStr==null?"0":priceStr.trim().replaceAll("[^0-9,.-]","");
    if (s.indexOf(',')>=0 && s.indexOf('.')<0) s = s.replace(".","").replace(',','.');
    else s = s.replace(",","");
    e.setPrice(new BigDecimal(s));

    int id = new EventDAO().create(e);
    response.sendRedirect(request.getContextPath()+"/Vista/EventosOrganizador.jsp?ok=1");
  } catch (Exception ex) {
    ex.printStackTrace();
    response.sendRedirect(request.getContextPath()+"/Vista/EventoNuevo.jsp?err=1");
  }
%>
