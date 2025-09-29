<%@ page import="java.util.*, java.math.BigDecimal, java.net.URLEncoder, java.nio.charset.StandardCharsets" %>
<%@ page import="dao.EventDAO, utils.Event" %>

<%!
  // helpers declarados (área de declaración, no scriptlet)
  BigDecimal dec(String s){
    if (s==null || s.trim().isEmpty()) return null;
    s = s.trim().replaceAll("[^0-9,.-]","");
    if (s.indexOf(',')>=0 && s.indexOf('.')<0) s = s.replace(".","").replace(',', '.');
    else s = s.replace(",", "");
    try { return new BigDecimal(s); } catch(Exception ex){ return null; }
  }
  String enc(String s){
    try { return (s==null? "" : URLEncoder.encode(s, StandardCharsets.UTF_8.toString())); }
    catch(Exception e){ return ""; }
  }
%>

<%
  // --- Parámetros ---
  String q      = request.getParameter("q");
  String genre  = request.getParameter("genre");  // columna genre
  String loc    = request.getParameter("loc");    // columna city
  String order  = request.getParameter("order");  // date | price_asc | price_desc
  BigDecimal pmin = dec(request.getParameter("pmin"));
  BigDecimal pmax = dec(request.getParameter("pmax"));

  int pageNum = 1, pageSize = 9;
  try { pageNum = Math.max(1, Integer.parseInt(request.getParameter("page"))); } catch(Exception ignore){}
  try {
    String ps = request.getParameter("pageSize");
    if (ps!=null && !ps.isBlank()) pageSize = Math.min(60, Math.max(3, Integer.parseInt(ps)));
  } catch(Exception ignore){}

  // --- DAO ---
  EventDAO dao = new EventDAO();
  List<Event> events = dao.search(q, genre, loc, pmin, pmax, order, pageNum, pageSize);
  int total          = dao.countSearch(q, genre, loc, pmin, pmax);
  int totalPages     = (int)Math.ceil(total / (double)pageSize);

  // --- QS base para links (sin 'page') ---
  String qsBase = "q=" + enc(q)
                + "&genre=" + enc(genre)
                + "&loc=" + enc(loc)
                + "&pmin=" + enc(request.getParameter("pmin"))
                + "&pmax=" + enc(request.getParameter("pmax"))
                + "&order=" + enc(order)
                + "&pageSize=" + pageSize;

  // --- Atributos para la vista ---
  request.setAttribute("events", events);
  request.setAttribute("total", total);
  request.setAttribute("page", pageNum);
  request.setAttribute("totalPages", totalPages);
  request.setAttribute("qsBase", qsBase);

  // para rellenar filtros
  request.setAttribute("f_q", q);
  request.setAttribute("f_genre", genre);
  request.setAttribute("f_loc", loc);
  request.setAttribute("f_order", order);
  request.setAttribute("f_pmin", request.getParameter("pmin"));
  request.setAttribute("f_pmax", request.getParameter("pmax"));

  // listas para selects
  request.setAttribute("genres", dao.listGenres());
  request.setAttribute("cities", dao.listCities());
%>
