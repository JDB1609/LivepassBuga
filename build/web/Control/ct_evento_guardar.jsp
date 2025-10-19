<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.EventDAO, utils.Event" %>
<%@ page import="java.time.*, java.time.format.DateTimeFormatter" %>
<%@ page import="java.math.BigDecimal" %>

<%
  request.setCharacterEncoding("UTF-8");
  final String ctx = request.getContextPath();

  // Guardias de sesión/rol
  Integer uid  = (Integer) session.getAttribute("userId");
  String  role = (String)  session.getAttribute("role");
  if (uid == null) { response.sendRedirect(ctx + "/Vista/Login.jsp"); return; }
  if (role == null || !"ORGANIZADOR".equalsIgnoreCase(role)) {
    response.sendRedirect(ctx + "/Vista/PaginaPrincipal.jsp"); return;
  }

  // Params
  int id = 0;
  try { id = Integer.parseInt(request.getParameter("id")); } catch (Exception ignore) {}

  String title   = request.getParameter("title");
  String venue   = request.getParameter("venue");
  String genre   = request.getParameter("genre");
  String city    = request.getParameter("city");
  String dtStr   = request.getParameter("datetime"); // yyyy-MM-dd'T'HH:mm
  String statusS = request.getParameter("status");
  int capacity   = 0;
  int sold       = 0;
  BigDecimal price = BigDecimal.ZERO;

  try { capacity = Math.max(0, Integer.parseInt(request.getParameter("capacity"))); } catch (Exception ignore) {}
  try { sold     = Math.max(0, Integer.parseInt(request.getParameter("sold"))); } catch (Exception ignore) {}
  try { price    = new BigDecimal(request.getParameter("price")); } catch (Exception ignore) {}

  if (title == null || title.trim().isEmpty()) {
    response.sendRedirect(ctx + "/Vista/EventosOrganizador.jsp?err=title");
    return;
  }

  LocalDateTime ldt = null;
  if (dtStr != null && !dtStr.isBlank()) {
    try {
      ldt = LocalDateTime.parse(dtStr, DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));
    } catch (Exception ignore) {}
  }

  Event e = new Event();
  e.setId(id);
  e.setOrganizerId(uid);
  e.setTitle(title);
  e.setVenue(venue);
  e.setGenre(genre);
  e.setCity(city);
  e.setDateTime(ldt);
  e.setCapacity(capacity);
  e.setSold(sold);
  e.setStatus(statusS);     // mapea a enum (tu setter ya lo hace)
  e.setPrice(price);

  EventDAO dao = new EventDAO();
  boolean ok;
  if (id <= 0) {
    int newId = dao.create(e);
    ok = newId > 0;
    response.sendRedirect(ok
      ? ctx + "/Vista/EventoEditar.jsp?id=" + newId + "&ok=1"
      : ctx + "/Vista/EventosOrganizador.jsp?err=create");
  } else {
    ok = dao.update(e);
    response.sendRedirect(ok
      ? ctx + "/Vista/EventoEditar.jsp?id=" + id + "&ok=1"
      : ctx + "/Vista/EventoEditar.jsp?id=" + id + "&err=save");
  }
%>
