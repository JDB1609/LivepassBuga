<%@ page import="java.util.*, java.math.BigDecimal, java.net.URLEncoder, java.nio.charset.StandardCharsets" %>
<%@ page import="dao.EventDAO, utils.Event" %>

<%!
    // ===== Helpers declarados (solo una vez) =====
    BigDecimal dec(String s){
        if (s == null || s.trim().isEmpty()) return null;
        s = s.trim().replaceAll("[^0-9,.-]", "");
        if (s.indexOf(',') >= 0 && s.indexOf('.') < 0) {
            s = s.replace(".", "").replace(',', '.');
        } else {
            s = s.replace(",", "");
        }
        try {
            return new BigDecimal(s);
        } catch (Exception ex) {
            return null;
        }
    }

    String enc(String s){
        try {
            return (s == null ? "" : URLEncoder.encode(s, StandardCharsets.UTF_8.toString()));
        } catch (Exception e) {
            return "";
        }
    }
%>

<%
    // ==========================
    //  PARÁMETROS DE FILTRO
    // ==========================
    String q     = request.getParameter("q");
    String genre = request.getParameter("genre");  // columna genre
    String loc   = request.getParameter("loc");    // columna city
    String order = request.getParameter("order");  // date | price_asc | price_desc

    BigDecimal pmin = dec(request.getParameter("pmin"));
    BigDecimal pmax = dec(request.getParameter("pmax"));

    int pageNum  = 1;
    int pageSize = 9;

    try {
        pageNum = Math.max(1, Integer.parseInt(request.getParameter("page")));
    } catch (Exception ignore) {}

    try {
        String ps = request.getParameter("pageSize");
        if (ps != null && !ps.isBlank()) {
            pageSize = Math.min(60, Math.max(3, Integer.parseInt(ps)));
        }
    } catch (Exception ignore) {}

    // ==========================
    //  DAO Y CONSULTA
    // ==========================
    EventDAO dao = new EventDAO();

    // lista paginada
    List<Event> events = dao.search(q, genre, loc, pmin, pmax, order, pageNum, pageSize);
    // total sin paginación
    int total = dao.countSearch(q, genre, loc, pmin, pmax);

    int totalPages = (int) Math.ceil(total / (double) pageSize);
    if (totalPages <= 0) totalPages = 1;
    if (pageNum > totalPages) pageNum = totalPages;

    // ==========================
    //  QUERY STRING BASE (para paginación)
    // ==========================
    String qsBase =
            "q="        + enc(q) +
            "&genre="   + enc(genre) +
            "&loc="     + enc(loc) +
            "&pmin="    + enc(request.getParameter("pmin")) +
            "&pmax="    + enc(request.getParameter("pmax")) +
            "&order="   + enc(order) +
            "&pageSize="+ pageSize;

    // ==========================
    //  ATRIBUTOS PARA LA VISTA
    // ==========================
    request.setAttribute("events",      events);
    request.setAttribute("total",       total);
    request.setAttribute("page",        pageNum);
    request.setAttribute("totalPages",  totalPages);
    request.setAttribute("qsBase",      qsBase);

    // para rellenar filtros
    request.setAttribute("f_q",     q);
    request.setAttribute("f_genre", genre);
    request.setAttribute("f_loc",   loc);
    request.setAttribute("f_order", order);
    request.setAttribute("f_pmin",  request.getParameter("pmin"));
    request.setAttribute("f_pmax",  request.getParameter("pmax"));

    // listas para selects (géneros y ciudades disponibles)
    request.setAttribute("genres", dao.listGenres());
    request.setAttribute("cities", dao.listCities());
%>
