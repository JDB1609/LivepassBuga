<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="utils.Event" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Explorar eventos</title>
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <main class="max-w-6xl mx-auto px-5 py-10">
    <h1 class="text-2xl font-extrabold mb-5">Explorar eventos</h1>

    <%-- Ejecuta el control: carga 'events', 'page', 'totalPages', etc. --%>
    <jsp:include page="../Control/ct_explorar_eventos.jsp" />

    <%
      List<Event> events = (List<Event>) request.getAttribute("events");
      int pageNum        = (Integer) request.getAttribute("page");
      int totalPages     = (Integer) request.getAttribute("totalPages");
      String qsBase      = (String) request.getAttribute("qsBase");
      java.time.format.DateTimeFormatter df = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    %>

    <!-- Filtros -->
    <form method="get" action="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp"
          class="glass ring rounded-2xl p-4 mb-6 grid md:grid-cols-6 gap-3">
      <input name="q" value="<%= (String)request.getAttribute("f_q")!=null?(String)request.getAttribute("f_q"):"" %>"
             placeholder="Buscar por título o lugar"
             class="md:col-span-2 px-4 py-2 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary"/>

      <select name="genre" class="ui-select md:col-span-1">
        <option value="">Género (todos)</option>
        <%
          List<String> genres = (List<String>) request.getAttribute("genres");
          String selG = (String) request.getAttribute("f_genre");
          if (genres!=null) for (String g: genres) {
        %>
          <option value="<%= g %>" <%= (selG!=null && selG.equalsIgnoreCase(g))? "selected":"" %>><%= g %></option>
        <% } %>
      </select>

      <select name="loc" class="ui-select md:col-span-1">
        <option value="">Ubicación (todas)</option>
        <%
          List<String> cities = (List<String>) request.getAttribute("cities");
          String selC = (String) request.getAttribute("f_loc");
          if (cities!=null) for (String c: cities) {
        %>
          <option value="<%= c %>" <%= (selC!=null && selC.equalsIgnoreCase(c))? "selected":"" %>><%= c %></option>
        <% } %>
      </select>

      <input name="pmin" inputmode="numeric" pattern="[0-9]*" placeholder="Precio min"
             value="<%= (String)request.getAttribute("f_pmin")!=null?(String)request.getAttribute("f_pmin"):"" %>"
             class="px-4 py-2 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary"/>

      <input name="pmax" inputmode="numeric" pattern="[0-9]*" placeholder="Precio máx"
             value="<%= (String)request.getAttribute("f_pmax")!=null?(String)request.getAttribute("f_pmax"):"" %>"
             class="px-4 py-2 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary"/>

      <div class="flex gap-2 md:col-span-2">
        <select name="order" class="ui-select">
          <%
            String ordSel = (String) request.getAttribute("f_order");
            boolean oDate  = (ordSel==null || ordSel.isBlank() || "date".equals(ordSel));
            boolean oAsc   = "price_asc".equals(ordSel);
            boolean oDesc  = "price_desc".equals(ordSel);
          %>
          <option value="date" <%= oDate?"selected":"" %>>Fecha</option>
          <option value="price_asc" <%= oAsc?"selected":"" %>>Precio ↑</option>
          <option value="price_desc" <%= oDesc?"selected":"" %>>Precio ↓</option>
        </select>

        <select name="pageSize" class="ui-select">
          <%
            int ps = 9;
            try { ps = Integer.parseInt(request.getParameter("pageSize")); } catch(Exception ignore){}
          %>
          <option value="9"  <%= ps==9 ?"selected":"" %>>9</option>
          <option value="12" <%= ps==12?"selected":"" %>>12</option>
          <option value="24" <%= ps==24?"selected":"" %>>24</option>
        </select>

        <button class="btn-primary ripple" type="submit">Filtrar</button>
      </div>
    </form>

    <!-- Resultados -->
    <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
      <%
        if (events!=null && !events.isEmpty()) {
          int i=0;
          for (Event e: events) {
            String dateStr = (e.getDateTime()!=null)? e.getDateTime().format(df) : e.getDate();
      %>
        <article class="glass ring rounded-2xl p-5 animate-fadeUp" style="animation-delay:<%= (i++*0.06) %>s">
          <h3 class="font-bold text-lg"><%= e.getTitle() %></h3>
          <p class="text-white/70 mt-1">📅 <%= dateStr %> • 📍 <%= e.getVenue() %></p>
          <p class="text-white/70">🎭 <%= e.getGenre()!=null?e.getGenre():"" %> • 🏙️ <%= e.getCity()!=null?e.getCity():"" %></p>
          <p class="mt-3 text-xl font-extrabold"><%= e.getPriceFormatted() %></p>
          <div class="mt-4 flex gap-2">
            <a class="btn-primary ripple" href="<%= request.getContextPath() %>/Vista/Checkout.jsp?eventId=<%= e.getId() %>&qty=1">Comprar</a>
            <a class="px-4 py-2 rounded-lg border border-white/15 hover:border-white/30 font-bold transition"
               href="<%= request.getContextPath() %>/Vista/EventoDetalle.jsp?id=<%= e.getId() %>">Detalles</a>
          </div>
        </article>
      <%
          }
        } else {
      %>
        <div class="col-span-full glass ring rounded-2xl p-8 text-center text-white/70">
          No hay eventos que coincidan con los filtros.
        </div>
      <% } %>
    </div>

    <!-- Paginación -->
    <%
      String base = request.getContextPath()+"/Vista/ExplorarEventos.jsp?"+qsBase;
    %>
    <div class="flex items-center justify-between mt-8 text-white/80">
      <div>
        <% if (pageNum>1) { %>
          <a class="px-3 py-2 rounded-lg border border-white/15 hover:border-white/30"
             href="<%= base+"&page="+(pageNum-1) %>">← Anterior</a>
        <% } %>
      </div>
      <div>Página <%= pageNum %> de <%= totalPages %></div>
      <div>
        <% if (pageNum<totalPages) { %>
          <a class="px-3 py-2 rounded-lg border border-white/15 hover:border-white/30"
             href="<%= base+"&page="+(pageNum+1) %>">Siguiente →</a>
        <% } %>
      </div>
    </div>
  </main>

  <script>
    // ripple
    (function(){ document.querySelectorAll('.ripple').forEach(b=>b.addEventListener('click',function(e){
      const r=this.getBoundingClientRect(),s=document.createElement('span'),z=Math.max(r.width,r.height);
      s.style.width=s.style.height=z+'px'; s.style.left=(e.clientX-r.left-z/2)+'px'; s.style.top=(e.clientY-r.top-z/2)+'px';
      this.appendChild(s); setTimeout(()=>s.remove(),600);
    }));})();
  </script>
</body>
</html>
