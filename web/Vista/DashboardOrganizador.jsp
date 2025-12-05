<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, java.math.BigDecimal, java.text.NumberFormat, java.util.Locale" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="dao.EventDAO, utils.Event" %>
<%
  // ===== Guard: sesión y rol =====
  Integer uid  = (Integer) session.getAttribute("userId");
  String role  = (String)  session.getAttribute("role");
  String name  = (String)  session.getAttribute("userName");

  if (uid == null) {
    response.sendRedirect(request.getContextPath() + "/Vista/Login.jsp");
    return;
  }
  if (role == null || !"ORGANIZADOR".equalsIgnoreCase(role)) {
    response.sendRedirect(request.getContextPath() + "/Vista/PaginaPrincipal.jsp");
    return;
  }

  // ===== Datos base =====
  EventDAO dao = new EventDAO();
  List<Event> events = dao.listByOrganizer(uid, null, null); // todos

  int publicados     = 0;
  int borradores     = 0;
  int finalizados    = 0;
  int totalVendidos  = 0;
  int totalCapacity  = 0;
  BigDecimal ingresos = BigDecimal.ZERO;

  if (events != null) {
    for (Event ev : events) {
      String st = (ev.getStatus() != null ? ev.getStatus().name() : "BORRADOR");

      if ("PUBLICADO".equalsIgnoreCase(st)) {
        publicados++;
      } else if ("FINALIZADO".equalsIgnoreCase(st)) {
        finalizados++;
      } else {
        borradores++;
      }

      int vendidos = Math.max(0, ev.getSold());
      int cap      = Math.max(0, ev.getCapacity());

      totalVendidos += vendidos;
      totalCapacity += cap;

      if (ev.getPriceValue() != null) {
        ingresos = ingresos.add(
          ev.getPriceValue().multiply(BigDecimal.valueOf(vendidos))
        );
      }
    }
  }

  int totalEventos   = (events != null ? events.size() : 0);
  double ocupacionPorc = (totalCapacity > 0)
      ? (totalVendidos * 100.0 / totalCapacity)
      : 0.0;

  DateTimeFormatter df = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
  NumberFormat COP = NumberFormat.getCurrencyInstance(new Locale("es", "CO"));

  // ===== Top 5 por ventas (para gráfico) =====
  List<Event> topBySold = new ArrayList<Event>();
  if (events != null) {
    topBySold.addAll(events);
    Collections.sort(topBySold, new Comparator<Event>() {
      public int compare(Event a, Event b) {
        int soldA = Math.max(0, a.getSold());
        int soldB = Math.max(0, b.getSold());
        return Integer.compare(soldB, soldA);
      }
    });
  }

  int topN    = Math.min(5, topBySold.size());
  int maxSold = 0;
  for (int i = 0; i < topN; i++) {
    maxSold = Math.max(maxSold, Math.max(0, topBySold.get(i).getSold()));
  }
  if (maxSold == 0) maxSold = 1;

  // ===== Top 5 por ingresos (tabla) =====
  class Row {
    String title;
    int sold;
    BigDecimal revenue;
    Row(String t, int s, BigDecimal r) {
      title = t;
      sold = s;
      revenue = r;
    }
  }

  List<Row> topByRevenue = new ArrayList<Row>();
  if (events != null) {
    for (Event ev : events) {
      BigDecimal price = (ev.getPriceValue() != null ? ev.getPriceValue() : BigDecimal.ZERO);
      int sold = Math.max(0, ev.getSold());
      BigDecimal rev = price.multiply(BigDecimal.valueOf(sold));
      String title = (ev.getTitle() != null ? ev.getTitle() : "(sin título)");
      topByRevenue.add(new Row(title, sold, rev));
    }
    Collections.sort(topByRevenue, new Comparator<Row>() {
      public int compare(Row x, Row y) {
        return y.revenue.compareTo(x.revenue);
      }
    });
    if (topByRevenue.size() > 5) {
      topByRevenue = topByRevenue.subList(0, 5);
    }
  }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>

  <title>Panel — Organizador</title>

  <!-- Tailwind CDN -->
  <script src="https://cdn.tailwindcss.com"></script>

  <!-- Chart.js -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

  <style>
    :root{
      --bg:#050712;
      --card:#0f1720;
      --muted:rgba(255,255,255,.65);
    }
    body{
      background:radial-gradient(circle at top,#111827 0,#050712 45%);
      font-family: Inter, ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial;
      -webkit-font-smoothing:antialiased;
      overflow-x:hidden;
      scroll-behavior:smooth;
    }
    .glass {
      background: linear-gradient(145deg, rgba(15,23,32,0.96), rgba(15,23,32,0.9));
      border-radius: 18px;
      box-shadow: 0 18px 45px rgba(0,0,0,.75), 0 0 0 1px rgba(148,163,184,.22);
      padding: 18px;
      transition: transform .18s ease-out, box-shadow .18s ease-out, border-color .18s ease-out;
      border: 1px solid rgba(148,163,184,.2);
    }
    .glass:hover{
      transform: translateY(-1px);
      box-shadow: 0 22px 60px rgba(0,0,0,.9);
      border-color: rgba(94,234,212,.6);
    }
    .metric {
      border-radius: 14px;
      padding: 18px;
      background: radial-gradient(circle at top left, rgba(94,234,212,.22), transparent 55%) rgba(15,23,32,.98);
      box-shadow: 0 10px 30px rgba(0,0,0,.65);
      border: 1px solid rgba(148,163,184,.28);
    }
    .k {
      font-size:1.7rem;
      font-weight:800;
      color: #fff;
    }
    .muted { color: var(--muted); }
    .pill {
      font-size: .75rem;
      padding:.25rem .6rem;
      border-radius: 9999px;
      font-weight:700;
    }
    .bar-bg{
      height:8px;
      border-radius:9999px;
      background:rgba(255,255,255,.06)
    }
    .bar-fg{
      height:8px;
      border-radius:9999px;
      background:#6c5ce7;
      box-shadow:0 0 0 1px rgba(255,255,255,.04) inset
    }
    .truncate-2 {
      overflow:hidden;
      text-overflow:ellipsis;
      display:-webkit-box;
      -webkit-line-clamp:2;
      -webkit-box-orient:vertical;
    }
    .text-aqua { color: #22e3c4; }
    .btn-primary{
      background: linear-gradient(90deg,#6c5ce7,#22e3c4);
      color:#fff;
      padding:.6rem 1rem;
      border-radius: 999px;
      font-weight:800;
      display:inline-flex;
      align-items:center;
      justify-content:center;
      gap:.35rem;
      box-shadow:0 10px 25px rgba(88,28,135,.7);
      font-size:.9rem;
    }
    .btn-ghost{
      border-radius:999px;
      padding:.45rem .9rem;
      font-weight:600;
      border:1px solid rgba(148,163,184,.38);
      background:rgba(15,23,42,.75);
      color:#e6eef3;
      display:inline-flex;
      align-items:center;
      justify-content:center;
      gap:.35rem;
      font-size:.85rem;
    }
    .btn-ghost.active{
      border-color:#22e3c4;
      background:rgba(34,227,196,.12);
      color:#e0fdfa;
    }
    .badge-soft{
      padding: .18rem .55rem;
      border-radius:999px;
      border:1px solid rgba(148,163,184,.4);
      font-size:.7rem;
      text-transform:uppercase;
      letter-spacing:.06em;
      color:#e5e7eb;
      background:rgba(15,23,42,.7);
    }
    .dash-grid{
      display:grid;
      grid-template-columns:minmax(0,1fr);
      gap:1.5rem;
    }
    @media (min-width:1024px){
      .dash-grid{
        grid-template-columns:minmax(0,2.1fr) minmax(0,1.1fr);
      }
    }
    .chart-card{
      min-height:260px;
      display:flex;
      flex-direction:column;
    }
    .ripple{
      position:relative;
      overflow:hidden;
    }
    .tag-dot{
      width:7px;
      height:7px;
      border-radius:999px;
      display:inline-block;
      margin-right:.4rem;
    }
  </style>
</head>
<body class="text-white">

  <!-- NAV ESTÁNDAR -->
  <%@ include file="../Includes/nav_base.jspf" %>

  <main class="max-w-6xl mx-auto px-4 sm:px-6 py-8 sm:py-10 space-y-6">
    <!-- header -->
    <section class="flex flex-col md:flex-row md:items-end md:justify-between gap-4">
      <div>
        <div class="flex items-center gap-2 mb-2">
          <span class="badge-soft">Panel en vivo</span>
          <% if (totalEventos > 0) { %>
            <span class="text-xs text-emerald-300/80">
              <span class="inline-block w-1.5 h-1.5 rounded-full bg-emerald-400 mr-1 animate-pulse"></span>
              <%= totalEventos %> evento(s) cargados
            </span>
          <% } %>
        </div>
        <h1 class="text-3xl md:text-4xl font-extrabold tracking-tight">
          Hola,
          <span class="text-aqua"><%= (name != null ? name : "organizador") %></span>
        </h1>
        <p class="muted mt-1 text-sm md:text-base">
          Visualiza el rendimiento de tus eventos y detecta rápido qué necesita atención.
        </p>
      </div>
      <div class="flex flex-wrap gap-3">
        <a href="<%= request.getContextPath() %>/Vista/EventoNuevo.jsp" class="btn-primary ripple">
          + Crear evento
        </a>
        <a href="<%= request.getContextPath() %>/Vista/EventosOrganizador.jsp" class="btn-ghost ripple">
          Mis eventos
        </a>
        <a href="<%= request.getContextPath() %>/Vista/ReporteVentas.jsp" class="btn-ghost ripple">
          Reportes
        </a>
      </div>
    </section>

    <!-- métricas -->
    <section class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
      <div class="metric">
        <div class="flex items-center justify-between">
          <span class="muted text-xs uppercase tracking-wide">Publicados</span>
          <span class="tag-dot bg-emerald-400"></span>
        </div>
        <div class="k mt-1"><%= publicados %></div>
        <p class="text-[0.7rem] text-white/60 mt-1">Eventos visibles para el público.</p>
      </div>
      <div class="metric">
        <div class="flex items-center justify-between">
          <span class="muted text-xs uppercase tracking-wide">Borradores</span>
          <span class="tag-dot bg-amber-300"></span>
        </div>
        <div class="k mt-1"><%= borradores %></div>
        <p class="text-[0.7rem] text-white/60 mt-1">Eventos en preparación.</p>
      </div>
      <div class="metric">
        <div class="flex items-center justify-between">
          <span class="muted text-xs uppercase tracking-wide">Finalizados</span>
          <span class="tag-dot bg-slate-300"></span>
        </div>
        <div class="k mt-1"><%= finalizados %></div>
        <p class="text-[0.7rem] text-white/60 mt-1">Eventos que ya terminaron.</p>
      </div>
      <div class="metric">
        <div class="flex items-center justify-between">
          <span class="muted text-xs uppercase tracking-wide">Tickets vendidos</span>
          <span class="tag-dot bg-sky-400"></span>
        </div>
        <div class="k mt-1"><%= totalVendidos %></div>
        <p class="text-[0.7rem] text-white/60 mt-1">Suma de todos los tickets.</p>
      </div>
      <div class="metric">
        <div class="flex items-center justify-between">
          <span class="muted text-xs uppercase tracking-wide">Ingresos</span>
          <span class="tag-dot bg-fuchsia-400"></span>
        </div>
        <div class="k mt-1 text-emerald-200"><%= COP.format(ingresos) %></div>
        <p class="text-[0.7rem] text-white/60 mt-1">Antes de impuestos y comisiones.</p>
      </div>
    </section>

    <!-- grilla principal -->
    <section class="dash-grid mt-3 sm:mt-5">
      <!-- columna izquierda -->
      <div class="space-y-6">
        <!-- resumen rápido -->
        <div class="glass p-5">
          <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
            <div>
              <h3 class="font-semibold text-sm text-slate-100">Resumen rápido</h3>
              <p class="muted text-xs mt-1">
                Ocupación global y capacidad total configurada para tus eventos.
              </p>
            </div>
            <div class="flex flex-wrap gap-3 text-xs">
              <div class="px-3 py-2 rounded-xl bg-emerald-500/15 border border-emerald-400/40">
                Ocupación global:
                <span class="font-bold text-emerald-300">
                  <%= String.format(Locale.US, "%.1f", ocupacionPorc) %>%
                </span>
              </div>
              <div class="px-3 py-2 rounded-xl bg-sky-500/10 border border-sky-400/40">
                Capacidad total:
                <span class="font-semibold text-sky-200"><%= totalCapacity %></span>
              </div>
              <div class="px-3 py-2 rounded-xl bg-fuchsia-500/10 border border-fuchsia-400/40">
                Eventos:
                <span class="font-semibold text-fuchsia-200"><%= totalEventos %></span>
              </div>
            </div>
          </div>
        </div>

        <!-- line chart -->
        <div class="glass chart-card">
          <div class="flex items-start justify-between gap-4">
            <div>
              <h3 class="font-bold text-lg">Tendencia de ventas</h3>
              <p class="muted text-sm">Ventas e ingresos de tus eventos con más movimiento.</p>
            </div>
            <div class="muted text-[0.7rem] mt-1 text-right">
              Se muestran hasta 5 eventos con mayores ventas.
            </div>
          </div>
          <div class="mt-4 flex-1">
            <canvas id="salesLineChart" class="w-full h-full"></canvas>
          </div>
        </div>

        <!-- canales + demografía -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div class="glass p-6">
            <div class="flex items-center justify-between">
              <div>
                <h4 class="font-bold text-sm">Canales de venta</h4>
                <p class="muted text-xs mb-2">Ejemplo de cómo se podrían distribuir tus tickets.</p>
              </div>
              <span class="badge-soft">Demo</span>
            </div>
            <div class="h-48">
              <canvas id="channelsBar" class="w-full h-full"></canvas>
            </div>
          </div>

          <div class="glass p-6">
            <div class="flex items-center justify-between">
              <div>
                <h4 class="font-bold text-sm">Demografía de audiencia</h4>
                <p class="muted text-xs mb-2">Edades de ejemplo para visualizar tu público.</p>
              </div>
            </div>
            <div class="flex items-center gap-4">
              <div class="w-32 h-32">
                <canvas id="demoDonut" class="w-full h-full"></canvas>
              </div>
              <div class="flex-1 text-xs md:text-sm">
                <div class="mb-2">
                  <span class="inline-block w-3 h-3 rounded mr-2" style="background:#6c5ce7"></span> 18-25: 28%
                </div>
                <div class="mb-2">
                  <span class="inline-block w-3 h-3 rounded mr-2" style="background:#22e3c4"></span> 26-35: 42%
                </div>
                <div class="mb-2">
                  <span class="inline-block w-3 h-3 rounded mr-2" style="background:#ffb86b"></span> 36-50: 18%
                </div>
                <div class="mb-2">
                  <span class="inline-block w-3 h-3 rounded mr-2" style="background:#ff6b6b"></span> Otros: 12%
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- próximos eventos con filtros -->
        <div class="glass p-6">
          <div class="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
            <div>
              <h3 class="font-bold text-sm md:text-base">Próximos eventos</h3>
              <p class="muted text-xs">
                Filtra por estado o busca por nombre para encontrar rápido un evento.
              </p>
            </div>
            <div class="flex flex-col gap-2 md:items-end">
              <div class="flex flex-wrap gap-2">
                <button type="button" class="btn-ghost ripple active" data-status-filter="ALL">Todos</button>
                <button type="button" class="btn-ghost ripple" data-status-filter="PUBLICADO">Publicados</button>
                <button type="button" class="btn-ghost ripple" data-status-filter="BORRADOR">Borradores</button>
                <button type="button" class="btn-ghost ripple" data-status-filter="FINALIZADO">Finalizados</button>
              </div>
              <div class="relative mt-1 w-full md:w-64">
                <input id="tableSearch"
                       class="w-full bg-slate-900/60 border border-slate-600/70 rounded-lg py-1.5 px-3 text-xs text-slate-100 placeholder:text-slate-500 outline-none focus:ring-1 focus:ring-emerald-400 focus:border-emerald-400"
                       type="text" placeholder="Buscar evento por nombre..." />
              </div>
            </div>
          </div>

          <div class="mt-4 overflow-x-auto">
            <table class="w-full min-w-full text-sm" style="border-collapse:separate; border-spacing:0;">
              <thead>
                <tr class="text-left text-white/70 text-xs border-b border-white/5">
                  <th class="py-2 pr-3" style="width:40%;">Evento</th>
                  <th class="py-2 pr-3">Fecha & lugar</th>
                  <th class="py-2 pr-3">Ocupación</th>
                  <th class="py-2 pr-3">Ingresos</th>
                  <th class="py-2 pr-3">Estado</th>
                </tr>
              </thead>
              <tbody class="text-white/90 text-xs sm:text-sm">
                <%
                  if (events != null && !events.isEmpty()) {
                    int max = Math.min(20, events.size());
                    for (int idx = 0; idx < max; idx++) {
                      Event ev = events.get(idx);
                      String st = (ev.getStatus() != null ? ev.getStatus().name() : "BORRADOR");

                      String pillClass;
                      if ("PUBLICADO".equalsIgnoreCase(st)) {
                        pillClass = "bg-emerald-500/20 text-emerald-200";
                      } else if ("RECHAZADO".equalsIgnoreCase(st) || "CANCELADO".equalsIgnoreCase(st)) {
                        pillClass = "bg-red-500/20 text-red-200";
                      } else if ("FINALIZADO".equalsIgnoreCase(st)) {
                        pillClass = "bg-white text-black";
                      } else {
                        pillClass = "bg-yellow-500/20 text-yellow-200";
                      }

                      String dateStr = "-";
                      if (ev.getDateTime() != null) {
                        dateStr = ev.getDateTime().format(df);
                      } else if (ev.getDate() != null) {
                        dateStr = ev.getDate();
                      }

                      int cap = Math.max(0, ev.getCapacity());
                      int sold = Math.max(0, ev.getSold());
                      int percent = (cap > 0 ? (int)Math.round((sold * 100.0) / cap) : 0);

                      BigDecimal price = (ev.getPriceValue() != null ? ev.getPriceValue() : BigDecimal.ZERO);
                      BigDecimal rev = price.multiply(BigDecimal.valueOf(sold));

                      String title = (ev.getTitle() != null ? ev.getTitle() : "(sin título)");
                %>
                <tr class="border-t border-white/5 hover:bg-slate-900/70 transition-colors"
                    data-event-row="1"
                    data-status="<%= st.toUpperCase() %>"
                    data-title="<%= title.toLowerCase().replace("\"","'") %>">
                  <td class="py-3 pr-3 align-top">
                    <div class="font-semibold truncate-2">
                      <%= title %>
                    </div>
                    <div class="muted text-[0.7rem] mt-1">
                      <%= (ev.getVenue() != null ? ev.getVenue() : "") %>
                    </div>
                  </td>
                  <td class="py-3 pr-3 align-top">
                    <div class="muted text-xs"><%= dateStr %></div>
                  </td>
                  <td class="py-3 pr-3 align-top">
                    <div class="text-xs sm:text-sm"><%= sold %> / <%= cap %></div>
                    <div class="bar-bg mt-2">
                      <div class="bar-fg" style="width:<%= percent %>%"></div>
                    </div>
                  </td>
                  <td class="py-3 pr-3 font-semibold align-top whitespace-nowrap">
                    <%= COP.format(rev) %>
                  </td>
                  <td class="py-3 pr-3 align-top">
                    <span class="pill <%= pillClass %> text-[0.7rem] sm:text-[0.75rem]"><%= st %></span>
                  </td>
                </tr>
                <%
                    }
                  } else {
                %>
                <tr>
                  <td colspan="5" class="py-6 text-center muted text-sm">
                    Aún no tienes eventos creados. Empieza creando tu primer evento arriba.
                  </td>
                </tr>
                <% } %>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- columna derecha -->
      <div class="space-y-6">
        <div class="glass p-6">
          <div class="flex items-center justify-between">
            <h4 class="font-bold text-sm md:text-base">Tasa de ocupación</h4>
            <span class="badge-soft">Vista global</span>
          </div>
          <p class="muted text-xs mt-1">Relación entre tickets vendidos y la capacidad total configurada.</p>
          <div class="mt-4 flex items-center gap-6">
            <div class="w-36 h-36">
              <canvas id="occupancyDonut" class="w-full h-full"></canvas>
            </div>
            <div>
              <div class="text-xs muted">Vendidos</div>
              <div class="font-bold text-2xl"><%= totalVendidos %></div>
              <div class="text-xs muted mt-3">Disponibles aproximados</div>
              <div class="font-semibold">
                <%= Math.max(0, totalCapacity - totalVendidos) %>
              </div>
              <div class="text-[0.7rem] muted mt-2">
                Ocupación global:
                <span class="text-emerald-300 font-semibold">
                  <%= String.format(Locale.US, "%.1f", ocupacionPorc) %>%
                </span>
              </div>
            </div>
          </div>
        </div>

        <div class="glass p-6">
          <h4 class="font-bold text-sm md:text-base">Top por ingresos</h4>
          <p class="muted text-xs mt-1">Tus eventos que más dinero han generado.</p>

          <div class="mt-4">
            <% if (topByRevenue != null && !topByRevenue.isEmpty()) { %>
              <ul class="space-y-3">
                <% for (Row r : topByRevenue) { %>
                  <li class="flex items-center justify-between gap-3">
                    <div class="truncate-2">
                      <div class="font-semibold text-sm"><%= r.title %></div>
                      <div class="muted text-[0.75rem]"><%= r.sold %> tickets vendidos</div>
                    </div>
                    <div class="font-semibold whitespace-nowrap text-emerald-200 text-sm">
                      <%= COP.format(r.revenue) %>
                    </div>
                  </li>
                <% } %>
              </ul>
            <% } else { %>
              <div class="muted text-xs">Sin datos de ingresos todavía.</div>
            <% } %>
          </div>
        </div>

        <div class="glass p-4">
          <h5 class="font-bold text-sm md:text-base">Acciones rápidas</h5>
          <p class="muted text-xs mt-1">Atajos para tareas frecuentes.</p>
          <div class="mt-3 flex flex-col gap-2">
            <a class="btn-ghost ripple" href="<%= request.getContextPath() %>/Vista/EventoNuevo.jsp">
              + Crear nuevo evento
            </a>
            <a class="btn-ghost ripple" href="<%= request.getContextPath() %>/Vista/EventosOrganizador.jsp">
              Administrar eventos
            </a>
            <a class="btn-ghost ripple" href="<%= request.getContextPath() %>/Vista/ReporteVentas.jsp">
              Exportar reportes
            </a>
          </div>
        </div>
      </div>
    </section>
  </main>

  <footer class="max-w-6xl mx-auto px-4 sm:px-6 pb-10 text-white/50 text-[0.7rem] md:text-xs">
    LivePass Buga • Panel de organizador
  </footer>

  <!-- Scripts charts + interactividad -->
  <script>
    // datos top ventas
    const labelsTopSold = [
      <% for (int i = 0; i < topN; i++) {
           Event ev = topBySold.get(i);
           String title = (ev.getTitle() != null ? ev.getTitle().replace("\"","'") : "(sin título)");
      %>
        "<%= title %>"<%= (i < topN - 1 ? "," : "") %>
      <% } %>
    ];
    const dataTopSold = [
      <% for (int i = 0; i < topN; i++) { Event ev = topBySold.get(i); %>
        <%= Math.max(0, ev.getSold()) %><%= (i < topN - 1 ? "," : "") %>
      <% } %>
    ];
    const dataTopRevenue = [
      <% for (int i = 0; i < topN; i++) {
           Event ev = topBySold.get(i);
           BigDecimal price = (ev.getPriceValue() != null ? ev.getPriceValue() : BigDecimal.ZERO);
           BigDecimal rev = price.multiply(BigDecimal.valueOf(Math.max(0, ev.getSold())));
      %>
        <%= rev.longValue() %><%= (i < topN - 1 ? "," : "") %>
      <% } %>
    ];

    const channelsLabels = ["Web Oficial","Taquilla","App Móvil","Revendedores"];
    const channelsValues = [45, 28, 20, 7];
    const demoValues     = [28, 42, 18, 12];

    const soldTotal      = <%= totalVendidos %>;
    const totalCapacity  = <%= totalCapacity %>;
    const approxAvailable = Math.max(0, totalCapacity - soldTotal);
    const occupancyValues = [soldTotal, approxAvailable];

    // line chart
    const ctxLine = document.getElementById('salesLineChart').getContext('2d');
    new Chart(ctxLine, {
      type: 'line',
      data: {
        labels: labelsTopSold.length ? labelsTopSold : ['Sin datos'],
        datasets: [
          {
            label: 'Entradas vendidas',
            data: dataTopSold.length ? dataTopSold : [0],
            tension: 0.4,
            borderWidth: 2,
            borderColor: '#6c5ce7',
            backgroundColor: 'rgba(108,92,231,0.06)',
            pointRadius: 3
          },
          {
            label: 'Ingresos (COP)',
            data: dataTopRevenue.length ? dataTopRevenue : [0],
            tension: 0.4,
            borderWidth: 2,
            borderColor: '#22e3c4',
            backgroundColor: 'rgba(34,227,196,0.08)',
            pointRadius: 3,
            yAxisID: 'y_rev'
          }
        ]
      },
      options: {
        maintainAspectRatio: false,
        scales: {
          y: {
            beginAtZero:true,
            ticks: { color: '#cbd5e1' }
          },
          y_rev: {
            position: 'right',
            grid: { drawOnChartArea:false },
            ticks: { color:'#cbd5e1' }
          },
          x: {
            ticks: { color:'#cbd5e1' }
          }
        },
        plugins: {
          legend: { labels: { color: '#cbd5e1' } },
          tooltip: { mode: 'index', intersect: false }
        }
      }
    });

    // bar canales
    const ctxBar = document.getElementById('channelsBar').getContext('2d');
    new Chart(ctxBar, {
      type: 'bar',
      data: {
        labels: channelsLabels,
        datasets: [{
          label: 'Porcentaje',
          data: channelsValues,
          borderRadius: 6
        }]
      },
      options: {
        maintainAspectRatio:false,
        scales: {
          x:{ ticks:{ color:'#cbd5e1' } },
          y:{ beginAtZero:true, ticks:{ color:'#cbd5e1' } }
        },
        plugins:{ legend:{ display:false } }
      }
    });

    // donut demo
    const ctxDemo = document.getElementById('demoDonut').getContext('2d');
    new Chart(ctxDemo, {
      type:'doughnut',
      data: {
        labels:['18-25','26-35','36-50','Otros'],
        datasets:[{ data: demoValues, hoverOffset:4 }]
      },
      options:{
        maintainAspectRatio:true,
        plugins:{ legend:{ display:false } }
      }
    });

    // donut ocupación
    const ctxOcc = document.getElementById('occupancyDonut').getContext('2d');
    new Chart(ctxOcc, {
      type:'doughnut',
      data: {
        labels:['Vendidos','Disponibles'],
        datasets:[{
          data: occupancyValues,
          backgroundColor:['#fb4b6a','#2b2f36']
        }]
      },
      options:{
        maintainAspectRatio:true,
        plugins:{
          legend:{
            position:'bottom',
            labels:{ color:'#cbd5e1' }
          }
        }
      }
    });

    // ripple
    (function(){
      document.querySelectorAll('.ripple').forEach(function(btn){
        btn.addEventListener('click', function(e){
          const rect = this.getBoundingClientRect();
          const span = document.createElement('span');
          const size = Math.max(rect.width, rect.height);

          span.style.width  = size + 'px';
          span.style.height = size + 'px';
          span.style.left   = (e.clientX - rect.left - size/2) + 'px';
          span.style.top    = (e.clientY - rect.top - size/2) + 'px';

          span.style.position      = 'absolute';
          span.style.borderRadius  = '50%';
          span.style.transform     = 'scale(0)';
          span.style.opacity       = '0.35';
          span.style.background    = 'linear-gradient(90deg,#6c5ce7,#22e3c4)';
          span.style.pointerEvents = 'none';
          span.style.transition    = 'transform .6s, opacity .6s';

          this.appendChild(span);

          requestAnimationFrame(function(){
            span.style.transform = 'scale(1)';
            span.style.opacity   = '0';
          });
          setTimeout(function(){ span.remove(); }, 700);
        });
      });
    })();

    // filtros de tabla (estado + búsqueda rápida)
    (function(){
      const rows = Array.from(document.querySelectorAll('[data-event-row]'));
      const searchInput = document.getElementById('tableSearch');
      const statusButtons = Array.from(document.querySelectorAll('[data-status-filter]'));
      let currentStatus = 'ALL';

      function applyFilters(){
        const text = (searchInput.value || '').toLowerCase().trim();

        rows.forEach(row => {
          const title  = (row.getAttribute('data-title') || '').toLowerCase();
          const status = (row.getAttribute('data-status') || '').toUpperCase();

          const matchesStatus = (currentStatus === 'ALL') || (status === currentStatus);
          const matchesText   = !text || title.indexOf(text) !== -1;

          row.style.display = (matchesStatus && matchesText) ? '' : 'none';
        });
      }

      statusButtons.forEach(btn => {
        btn.addEventListener('click', () => {
          statusButtons.forEach(b => b.classList.remove('active'));
          btn.classList.add('active');
          currentStatus = (btn.getAttribute('data-status-filter') || 'ALL').toUpperCase();
          applyFilters();
        });
      });

      if (searchInput) {
        searchInput.addEventListener('input', applyFilters);
      }
    })();
  </script>
</body>
</html>
