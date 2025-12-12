<%@page import="utils.ChartPoint"%>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, dao.EventDAO, utils.Event, dao.DashboardDAO" %>

<%
    Long uid  = (Long) session.getAttribute("adminId");
    String role  = (String) session.getAttribute("role");
    String name  = (String) session.getAttribute("adminNombre");

    if (uid == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }
    if (role == null || !"admin".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath()+"/Vista/PaginaPrincipal.jsp"); return;
    }
    DashboardDAO daodash= new DashboardDAO();
    int totalUsuarios = daodash.totalUsuarios();;
    int totalOrganizadores = daodash.totalOrganizadores();
    int totalEventos = daodash.totalEventos();
    int totalTickets = daodash.totalTickets();
    double totalComisiones = daodash.totalComisiones();

    EventDAO eventDAO = new EventDAO();
    int pageSize = 5;      // máximo 5 próximos eventos
    int offset   = 0;      // desde el primero

    
    List<Event> pendientes = eventDAO.listPendingPaged(pageSize, offset);

    List<ChartPoint> grafica1 = daodash.ticketsPorDia(7);
    List<ChartPoint> grafica2 = daodash.ticketsPorEvento();    
    request.setAttribute("grafica1", grafica1);
    request.setAttribute("grafica2", grafica2);
    // Mensaje flash de eventos
    String msgEvento = (String) session.getAttribute("msgEvento");
    if (msgEvento != null) {
        session.removeAttribute("msgEvento");
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="../Includes/head_base_administrador.jspf" %>
    <title>Panel — Administrador</title>
    <style>
      .metric { background: linear-gradient(180deg, rgba(255,255,255,.06), rgba(255,255,255,.04)); border-radius: 18px; padding: 18px; box-shadow: 0 10px 40px rgba(0,0,0,.45), inset 0 1px 0 rgba(255,255,255,.04); transition: transform .15s; }
      .metric:hover { transform: translateY(-2px); }
      .k { font-size: 1.7rem; font-weight: 800; }

      .boton-morado, .boton-negro { border-radius: 12px; font-weight: 700; transition: .2s; }
      .boton-morado { background: #6c5ce7; color:white; }
      .boton-negro  { background: transparent; border:1px solid white; color:white; }
      .boton-morado:hover { filter: brightness(1.1); }
      .boton-negro:hover  { background: rgba(255,255,255,0.15); }
      .boton-mini { padding: 8px 14px; font-size: 0.85rem; }

      .mensaje-exito { background-color: #22c55e; color:white; padding:12px; border-radius:8px; margin-bottom:16px; }
      .mensaje-error { background-color: #ef4444; color:white; padding:12px; border-radius:8px; margin-bottom:16px; }
    </style>      
</head>

<body class="text-white font-sans bg-[#0b0e16]">
<header class="sticky top-0 z-30 backdrop-blur bg-[#0b0e16] border-b border-white/10">
  <%@ include file="../Includes/nav_base_administrador.jspf" %>
</header>

<main class="max-w-6xl mx-auto px-5 py-10">
  <div class="mb-6">
    <h1 class="text-3xl md:text-4xl font-extrabold">Hola, <%= name %></h1>
    <p class="text-white/70 mt-1">Panel de administrador.</p>
  </div>

  <!-- Mostrar mensaje flash -->
  <% if (msgEvento != null) { %>
      <div class="mensaje-exito"><%= msgEvento %></div>
  <% } %>

  <!-- Botones superiores -->
  <section class="flex justify-end gap-3 mt-10">
    <a href="AprobacionEventos.jsp" class="boton-morado boton-mini">Aceptar / Rechazar</a>
    <a href="CrearAdministrador.jsp" class="boton-negro boton-mini">Crear Admin</a>
    <a href="SoporteAdministrador.jsp" class="boton-negro boton-mini">Responder PQRS</a>
    <a href="Reportes.jsp" class="boton-negro boton-mini">Reportes</a>
  </section>

  <!-- Métricas -->
  <section class="grid md:grid-cols-5 gap-4 mt-8">
    <div class="metric"><div class="text-white/70">Usuarios</div><div class="k"><%= totalUsuarios %></div></div>
    <div class="metric"><div class="text-white/70">Organizadores</div><div class="k"><%= totalOrganizadores %></div></div>
    <div class="metric"><div class="text-white/70">Eventos</div><div class="k"><%= totalEventos %></div></div>
    <div class="metric"><div class="text-white/70">Total Tickets</div><div class="k"><%= totalTickets %></div></div>
    <div class="metric"><div class="text-white/70">Total comisiones (10%)</div><div class="k">$<%= totalComisiones %></div></div>
  </section>

  <!-- === INICIO GRÁFICAS === -->
  <section class="mt-14 grid md:grid-cols-2 gap-6">

      <!-- GRÁFICA 1: Tickets vendidos por mes -->
      <div class="glass rounded-2xl p-6 ring">
          <h2 class="text-lg font-bold mb-3">Tickets Vendidos (Simulado)</h2>
          <canvas id="chartTickets"></canvas>
      </div>

      <!-- GRÁFICA 2: Comisiones generadas por mes -->
      <div class="glass rounded-2xl p-6 ring">
          <h2 class="text-lg font-bold mb-3">Comisiones Mensuales (Simulado)</h2>
          <canvas id="chartComisiones"></canvas>
      </div>

  </section>

  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <script>
      // === GRÁFICA 1: Tickets Vendidos (REAL) ===
        const ctx1 = document.getElementById("chartTickets");

          const labels1 = [
          <%
            List<utils.ChartPoint> graficaTickets = (List<utils.ChartPoint>) request.getAttribute("grafica1");
            if (graficaTickets != null && !graficaTickets.isEmpty()) {
                for (int i = 0; i < graficaTickets.size(); i++) {
                    utils.ChartPoint p = graficaTickets.get(i);
                    out.print("\"" + p.getLabel() + "\"");
                    if (i < graficaTickets.size() - 1) out.print(", ");
                }
            }
          %>
          ];

          const data1 = [
          <%
            if (graficaTickets != null && !graficaTickets.isEmpty()) {
                for (int i = 0; i < graficaTickets.size(); i++) {
                    utils.ChartPoint p = graficaTickets.get(i);
                    out.print(p.getValue());
                    if (i < graficaTickets.size() - 1) out.print(", ");
                }
            }
          %>
          ];

          new Chart(ctx1, {
            type: "line",
            data: {
              labels: labels1,
              datasets: [{
                label: "Tickets Vendidos",
                data: data1,
                borderColor: "rgba(106,106,255,0.8)",
                backgroundColor: "rgba(106,106,255,0.25)",
                borderWidth: 2,
                tension: 0.35
              }]
            },
            options: {
              responsive: true,
              plugins: { legend: { labels: { color: "white" } } },
              scales: {
                x: { ticks: { color: "white" } },
                y: { ticks: { color: "white" } }
              }
            }
          });

          // === GRÁFICA 2: Tickets x Evento (REAL) ===
          const ctx2 = document.getElementById("chartComisiones");

          const labels2 = [
          <%
            List<utils.ChartPoint> graficaComisiones = (List<utils.ChartPoint>) request.getAttribute("grafica2");
            if (graficaComisiones != null && !graficaComisiones.isEmpty()) {
                for (int i = 0; i < graficaComisiones.size(); i++) {
                    utils.ChartPoint p = graficaComisiones.get(i);
                    out.print("\"" + p.getLabel() + "\"");
                    if (i < graficaComisiones.size() - 1) out.print(", ");
                }
            }
          %>
          ];

          const data2 = [
          <%
            if (graficaComisiones != null && !graficaComisiones.isEmpty()) {
                for (int i = 0; i < graficaComisiones.size(); i++) {
                    utils.ChartPoint p = graficaComisiones.get(i);
                    out.print(p.getValue());
                    if (i < graficaComisiones.size() - 1) out.print(", ");
                }
            }
          %>
          ];

      new Chart(ctx2, {
        type: "bar",
        data: {
          labels: labels2,
          datasets: [{
            label: "Comisiones / Tickets por Evento",
            data: data2,
            backgroundColor: "rgba(255,99,132,0.45)",
            borderColor: "rgba(255,99,132,1)",
            borderWidth: 1
          }]
        },
        options: {
          responsive: true,
          plugins: { legend: { labels: { color: "white" } } },
          scales: {
            x: { ticks: { color: "white" } },
            y: { ticks: { color: "white" } }
          }
        }
      });
    </script> 

  
  
  
  
  <!-- Eventos pendientes -->
  <section class="mt-14 glass rounded-2xl p-6 ring">
    <h2 class="text-xl font-bold mb-2">Eventos pendientes</h2>
    <p class="text-white/70 mb-4">Máximo 5 próximos eventos por aprobar</p>

    <% if (pendientes != null && !pendientes.isEmpty()) { %>
      <div class="space-y-4">
        <% for (Event ev : pendientes) { %>
          <div class="p-4 rounded-xl bg-white/5 flex justify-between items-center">
            <div>
              <div class="font-bold"><%= ev.getTitle() %></div>
              <div class="text-white/60 text-sm"><%= ev.getVenue() %></div>
            </div>
            <div class="flex gap-2">
              <a href="../Control/ct_aprobar_evento_backoffice.jsp?id=<%= ev.getId() %>&action=aprobar"
                 class="boton-morado boton-mini">Aprobar</a>
              <a href="../Control/ct_aprobar_evento_backoffice.jsp?id=<%= ev.getId() %>&action=rechazar"
                 class="boton-negro boton-mini">Rechazar</a>
            </div>
          </div>
        <% } %>
      </div>
    <% } else { %>
      <div class="text-white/60">No hay eventos pendientes.</div>
    <% } %>
  </section>

</main>
</body>
</html>