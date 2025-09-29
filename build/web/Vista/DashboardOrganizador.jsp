<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, java.math.BigDecimal, java.text.NumberFormat, java.util.Locale" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="dao.EventDAO, utils.Event" %>
<%
  // ===== Guard: sesión y rol =====
  Integer uid  = (Integer) session.getAttribute("userId");
  String role  = (String)  session.getAttribute("role");
  String name  = (String)  session.getAttribute("userName");

  if (uid == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }
  if (role == null || !"ORGANIZADOR".equalsIgnoreCase(role)) {
    response.sendRedirect(request.getContextPath()+"/Vista/PaginaPrincipal.jsp"); return;
  }

  // ===== Datos base =====
  EventDAO dao = new EventDAO();
  List<Event> events = dao.listByOrganizer(uid, null, null); // todos, fecha DESC

  int publicados=0, borradores=0, finalizados=0, totalVendidos=0;
  BigDecimal ingresos = BigDecimal.ZERO;

  if (events != null) {
    for (Event ev : events) {
      String st = ev.getStatus()!=null? ev.getStatus().name() : "BORRADOR";
      if ("PUBLICADO".equalsIgnoreCase(st))  publicados++;
      else if ("FINALIZADO".equalsIgnoreCase(st)) finalizados++;
      else borradores++;

      int vendidos = Math.max(0, ev.getSold());
      totalVendidos += vendidos;
      if (ev.getPriceValue()!=null) {
        ingresos = ingresos.add(ev.getPriceValue().multiply(BigDecimal.valueOf(vendidos)));
      }
    }
  }

  DateTimeFormatter df = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
  NumberFormat COP = NumberFormat.getCurrencyInstance(new Locale("es","CO"));

  // ===== Top 5 por ventas (para gráfico) =====
  List<Event> topBySold = new ArrayList<Event>();
  if (events != null) topBySold.addAll(events);
  Collections.sort(topBySold, new Comparator<Event>() {
    public int compare(Event a, Event b) {
      return Integer.compare(Math.max(0,b.getSold()), Math.max(0,a.getSold()));
    }
  });
  int topN = Math.min(5, topBySold.size());
  int maxSold = 0;
  for (int i=0;i<topN;i++){ maxSold = Math.max(maxSold, Math.max(0, topBySold.get(i).getSold())); }
  if (maxSold==0) maxSold = 1;

  // ===== Top 5 por ingresos (tabla) =====
  class Row { String title; int sold; BigDecimal revenue; Row(String t,int s,BigDecimal r){title=t;sold=s;revenue=r;} }
  List<Row> topByRevenue = new ArrayList<Row>();
  if (events != null) {
    for (Event ev: events) {
      BigDecimal price = (ev.getPriceValue()!=null? ev.getPriceValue():BigDecimal.ZERO);
      BigDecimal rev   = price.multiply(BigDecimal.valueOf(Math.max(0, ev.getSold())));
      topByRevenue.add(new Row(ev.getTitle()!=null?ev.getTitle():"(sin título)", Math.max(0, ev.getSold()), rev));
    }
    Collections.sort(topByRevenue, new Comparator<Row>() {
      public int compare(Row x, Row y) { return y.revenue.compareTo(x.revenue); }
    });
    if (topByRevenue.size()>5) topByRevenue = topByRevenue.subList(0,5);
  }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Panel — Organizador</title>
  <style>
    .metric{background:linear-gradient(180deg,rgba(255,255,255,.06),rgba(255,255,255,.04));border-radius:18px;padding:18px;box-shadow:0 10px 40px rgba(0,0,0,.45),inset 0 1px 0 rgba(255,255,255,.04);transition:transform .15s,box-shadow .22s,background .22s}
    .metric:hover{transform:translateY(-2px);box-shadow:0 16px 50px rgba(0,0,0,.5)}
    .metric .k{font-size:1.7rem;font-weight:800;letter-spacing:-.02em}
    .btn-ghost{border-radius:12px;padding:10px 14px;font-weight:700;border:1px solid rgba(255,255,255,.14);background:rgba(255,255,255,.04);transition:border-color .2s,transform .12s,box-shadow .22s,background .2s}
    .btn-ghost:hover{transform:translateY(-1px);border-color:rgba(255,255,255,.3)}
    .ev:hover{transform:translateY(-2px);box-shadow:0 16px 50px rgba(0,0,0,.5)}
    .bar-bg{height:8px;border-radius:9999px;background:rgba(255,255,255,.12)}
    .bar-fg{height:8px;border-radius:9999px;background:#6c5ce7;box-shadow:0 0 0 1px rgba(255,255,255,.08) inset}
    .table{width:100%;border-collapse:separate;border-spacing:0}
    .table th,.table td{padding:.65rem .75rem;text-align:left}
    .table th{font-weight:700;color:#cbd5e1}
    .table tr{border-bottom:1px solid rgba(255,255,255,.08)}
  </style>
</head>
<body class="text-white font-sans">
  <header id="lp-nav" class="sticky top-0 z-30 backdrop-blur bg-[#0b0e16] border-b border-white/10">
    <div class="max-w-6xl mx-auto px-5 py-3 flex items-center justify-between">
      <a href="<%= request.getContextPath() %>/Vista/DashboardOrganizador.jsp" class="flex items-center gap-2 font-extrabold tracking-tight">
        <span class="inline-block w-3 h-3 rounded-sm" style="background:#00d1b2"></span> Livepass <span class="text-aqua">Buga</span>
      </a>
      <nav class="hidden sm:flex items-center gap-5 text-white/80">
        <a href="<%= request.getContextPath() %>/Vista/DashboardOrganizador.jsp" class="hover:text-white transition">Panel</a>
        <a href="<%= request.getContextPath() %>/Vista/EventosOrganizador.jsp" class="hover:text-white transition">Mis eventos</a>
        <a href="<%= request.getContextPath() %>/Vista/PaginaPrincipal.jsp" class="hover:text-white transition">Inicio</a>
        <a href="<%= request.getContextPath() %>/Control/ct_logout.jsp" class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30">Salir</a>
      </nav>
    </div>
  </header>

  <main class="max-w-6xl mx-auto px-5 py-10">
    <div class="flex flex-col md:flex-row md:items-end md:justify-between gap-4">
      <div>
        <h1 class="text-3xl md:text-4xl font-extrabold">Hola, <%= (name!=null? name : "organizador") %> 👋</h1>
        <p class="text-white/70 mt-1">Administra tus eventos, ventas y validaciones.</p>
      </div>
      <div class="flex flex-wrap gap-2">
        <a href="<%= request.getContextPath() %>/Vista/EventoNuevo.jsp" class="btn-primary ripple">+ Crear evento</a>
        <a href="<%= request.getContextPath() %>/Vista/EventosOrganizador.jsp" class="btn-ghost ripple">Ver mis eventos</a>
        <a href="<%= request.getContextPath() %>/Vista/PaginaPrincipal.jsp" class="btn-ghost ripple">Ir a inicio</a>
      </div>
    </div>

    <!-- Métricas -->
    <section class="grid md:grid-cols-5 gap-4 mt-8">
      <div class="metric"><div class="text-white/70">Publicados</div><div class="k"><%= publicados %></div></div>
      <div class="metric"><div class="text-white/70">Borradores</div><div class="k"><%= borradores %></div></div>
      <div class="metric"><div class="text-white/70">Finalizados</div><div class="k"><%= finalizados %></div></div>
      <div class="metric"><div class="text-white/70">Tickets vendidos</div><div class="k"><%= totalVendidos %></div></div>
      <div class="metric"><div class="text-white/70">Ingresos acumulados</div><div class="k"><%= COP.format(ingresos) %></div></div>
    </section>

    <!-- Rendimiento -->
    <section class="mt-10 grid lg:grid-cols-2 gap-6">
      <!-- Chart barras horizontales -->
      <div class="glass ring rounded-2xl p-6">
        <h3 class="font-bold text-lg mb-1">Ventas por evento (Top 5)</h3>
        <p class="text-white/60 mb-4">Comparativa de entradas vendidas</p>
        <%
          if (topN > 0) {
        %>
        <div class="space-y-4">
          <%
            for (int i=0;i<topN;i++){
              Event ev = topBySold.get(i);
              int sold = Math.max(0, ev.getSold());
              int pct  = (int)Math.round((sold * 100.0) / maxSold);
          %>
          <div>
            <div class="flex items-center justify-between">
              <div class="font-semibold truncate max-w-[70%]"><%= ev.getTitle()!=null? ev.getTitle() : "(sin título)" %></div>
              <div class="text-white/60 text-sm"><%= sold %> tickets</div>
            </div>
            <div class="bar-bg mt-2">
              <div class="bar-fg" style="width:<%= pct %>%"></div>
            </div>
          </div>
          <% } %>
        </div>
        <% } else { %>
          <div class="text-white/60">Aún no hay ventas registradas.</div>
        <% } %>
      </div>

      <!-- Tabla Top por ingresos -->
      <div class="glass ring rounded-2xl p-6">
        <h3 class="font-bold text-lg mb-1">Top por ingresos</h3>
        <p class="text-white/60 mb-4">Ingresos = vendidos × precio</p>
        <%
          if (topByRevenue!=null && !topByRevenue.isEmpty()) {
        %>
        <div class="overflow-x-auto">
          <table class="table">
            <thead>
              <tr>
                <th style="width:54%">Evento</th>
                <th>Vendidos</th>
                <th>Ingresos</th>
              </tr>
            </thead>
            <tbody>
            <% for (Row r: topByRevenue) { %>
              <tr>
                <td class="truncate"><%= r.title %></td>
                <td><%= r.sold %></td>
                <td class="font-semibold"><%= COP.format(r.revenue) %></td>
              </tr>
            <% } %>
            </tbody>
          </table>
        </div>
        <% } else { %>
          <div class="text-white/60">Sin datos de ingresos todavía.</div>
        <% } %>
      </div>
    </section>

    <!-- Últimos eventos -->
    <section class="mt-10">
      <div class="flex items-end justify-between mb-3">
        <div>
          <h2 class="text-2xl font-bold">Tus últimos eventos</h2>
          <p class="text-white/60">Ordenados por fecha (recientes primero)</p>
        </div>
        <a class="text-white/70 hover:text-white transition font-semibold"
           href="<%= request.getContextPath() %>/Vista/EventosOrganizador.jsp">Administrar todos →</a>
      </div>

      <div class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
        <%
          if (events != null && !events.isEmpty()) {
            int i=0, max= Math.min(6, events.size());
            for (int idx=0; idx<max; idx++) {
              Event ev = events.get(idx);
              String st = (ev.getStatus()!=null ? ev.getStatus().name() : "BORRADOR");
              String pill =
                 "PUBLICADO".equalsIgnoreCase(st) ? "bg-emerald-500/20 text-emerald-200"
               : "FINALIZADO".equalsIgnoreCase(st) ? "bg-white/15 text-white/80"
               : "bg-yellow-500/20 text-yellow-200";
              String dateStr = (ev.getDateTime()!=null) ? ev.getDateTime().format(df) : ev.getDate();
              int cap = Math.max(0, ev.getCapacity());
              int sold = Math.max(0, ev.getSold());
              int prog = (cap>0) ? (int)Math.round((sold*100.0)/cap) : 0;
              if (prog>100) prog=100;
        %>
        <article class="ev glass ring rounded-2xl p-5 animate-fadeUp" style="animation-delay:<%= (i++ * 0.06) %>s">
          <div class="flex items-center justify-between mb-2">
            <h3 class="font-bold text-lg line-clamp-1"><%= ev.getTitle()!=null?ev.getTitle():"(sin título)" %></h3>
            <span class="px-2.5 py-1 rounded-full text-xs font-bold <%= pill %>"><%= st %></span>
          </div>
          <p class="text-white/70">📅 <%= dateStr %></p>
          <p class="text-white/70">📍 <%= ev.getVenue()!=null? ev.getVenue():"" %></p>
          <p class="mt-2 text-white/80 text-sm">Capacidad: <%= cap %> • Vendidos: <%= sold %></p>
          <div class="bar-bg mt-2"><div class="bar-fg" style="width:<%= prog %>%"></div></div>
          <p class="font-extrabold mt-2"><%= ev.getPriceFormatted() %></p>

          <div class="mt-4 flex flex-wrap gap-2">
            <a class="btn-ghost ripple"
               href="<%= request.getContextPath() %>/Vista/DashboardOrganizador.jsp?eventId=<%= ev.getId() %>">Panel</a>
            <a class="btn-primary ripple"
               href="<%= request.getContextPath() %>/Vista/EventoEditar.jsp?id=<%= ev.getId() %>">Editar</a>
            <a class="btn-ghost ripple"
               href="<%= request.getContextPath() %>/Vista/EventoDetalle.jsp?id=<%= ev.getId() %>">Ver público</a>
          </div>
        </article>
        <%
            } // for
          } else {
        %>
        <div class="col-span-full glass ring rounded-2xl p-8 text-center text-white/70">
          Aún no has creado eventos. <a class="text-aqua font-bold" href="<%= request.getContextPath() %>/Vista/EventoNuevo.jsp">Crea el primero →</a>
        </div>
        <% } %>
      </div>
    </section>
  </main>

  <script>
    (function(){ document.querySelectorAll('.ripple').forEach(function(b){
      b.addEventListener('click',function(e){
        var r=this.getBoundingClientRect(),s=document.createElement('span'),z=Math.max(r.width,r.height);
        s.style.width=s.style.height=z+'px'; s.style.left=(e.clientX-r.left-z/2)+'px'; s.style.top=(e.clientY-r.top-z/2)+'px';
        this.appendChild(s); setTimeout(function(){s.remove();},600);
      });
    });})();
  </script>
</body>
</html>
