<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="utils.Event" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="../Includes/head_base.jspf" %>
    <title>Explorar eventos</title>

    <style>
        /* ====== HERO / CABECERA COMERCIAL ====== */
        .lp-hero {
            position: relative;
            border-radius: 26px;
            overflow: hidden;
            padding: 26px 22px;
            margin-bottom: 28px;
            background: radial-gradient(circle at top left,#1d4ed833,#020617),
                        radial-gradient(circle at bottom right,#8b5cf633,#020617);
            border: 1px solid rgba(148,163,184,.28);
            box-shadow: 0 26px 60px rgba(0,0,0,.8);
        }
        .lp-hero-bg {
            position: absolute;
            inset: 0;
            background-image: url("https://images.unsplash.com/photo-1518972559570-7cc1309f3229?auto=format&fit=crop&w=1600&q=80");
            background-size: cover;
            background-position: center;
            opacity: .35;
            mix-blend-mode: screen;
            pointer-events: none;
        }
        .lp-hero-gradient {
            position: absolute;
            inset: 0;
            background: radial-gradient(circle at top,#6366f180 0,transparent 55%),
                        radial-gradient(circle at bottom,#ec489980 0,transparent 52%);
            mix-blend-mode: soft-light;
            pointer-events: none;
        }
        .lp-hero-content {
            position: relative;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        .lp-hero-kicker {
            font-size: .78rem;
            letter-spacing: .18em;
            text-transform: uppercase;
            font-weight: 600;
            color: #c4b5fd;
        }
        .lp-hero-title {
            font-size: 1.9rem;
            line-height: 1.1;
            font-weight: 800;
        }
        .lp-hero-sub {
            font-size: .9rem;
            max-width: 32rem;
            color: rgba(226,232,240,.9);
        }
        .lp-hero-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 4px;
        }
        .lp-pill {
            padding: 4px 10px;
            border-radius: 999px;
            font-size: .75rem;
            font-weight: 600;
            background: rgba(15,23,42,.8);
            border: 1px solid rgba(148,163,184,.55);
            backdrop-filter: blur(10px);
        }

        /* ====== TIRA DE CATEGORÍAS CON IMAGEN ====== */
        .lp-strip {
            display: grid;
            grid-template-columns: repeat(3,minmax(0,1fr));
            gap: 10px;
            margin-bottom: 18px;
        }
        @media (max-width: 768px) {
            .lp-strip {
                grid-template-columns: repeat(2,minmax(0,1fr));
            }
        }
        .lp-strip-card {
            position: relative;
            overflow: hidden;
            border-radius: 18px;
            background: #020617;
            border: 1px solid rgba(30,64,175,.5);
        }
        .lp-strip-img {
            position: absolute;
            inset: 0;
            background-size: cover;
            background-position: center;
            opacity: .45;
            transform: scale(1.05);
            transition: transform .25s, opacity .25s;
        }
        .lp-strip-card:hover .lp-strip-img {
            opacity: .7;
            transform: scale(1.08);
        }
        .lp-strip-overlay {
            position: relative;
            padding: 10px 12px;
            display: flex;
            flex-direction: column;
            gap: 2px;
            backdrop-filter: blur(10px);
            background: linear-gradient(to right,rgba(15,23,42,.88),rgba(15,23,42,.55));
        }
        .lp-strip-title {
            font-size: .8rem;
            font-weight: 700;
        }
        .lp-strip-sub {
            font-size: .7rem;
            color: rgba(226,232,240,.85);
        }

        /* ====== LISTA ESTILO "GARAGE NATION" ====== */
        .event-row {
            display: grid;
            grid-template-columns: 90px 130px 1fr auto;
            gap: 20px;
            padding: 18px 20px;
            background: rgba(15,23,42,.92);
            border: 1px solid rgba(31,41,55,.9);
            border-radius: 18px;
            align-items: center;
            transition: background .25s, transform .18s, box-shadow .18s, border-color .18s;
        }
        .event-row:hover {
            background: radial-gradient(circle at top left,#111827,#020617);
            transform: translateY(-2px);
            box-shadow: 0 18px 40px rgba(0,0,0,.65);
            border-color: rgba(129,140,248,.9);
        }

        .date-block {
            font-size: .78rem;
            text-align: left;
            font-weight: 600;
            color: #fff;
            opacity: .85;
            line-height: 1.2;
            text-transform: uppercase;
        }
        .date-block span:nth-child(1) {
            font-size: 1.1rem;
            display: block;
        }

        .event-img {
            width: 130px;
            height: 88px;
            object-fit: cover;
            border-radius: 12px;
            box-shadow: 0 8px 18px rgba(0,0,0,.7);
        }

        .info-title {
            font-size: 1.05rem;
            font-weight: 700;
            margin-bottom: .2rem;
        }

        .info-sub {
            font-size: .82rem;
            opacity: .78;
        }

        .info-extra {
            font-size: .75rem;
            margin-top: .25rem;
            opacity: .75;
        }
        .info-price {
            margin-top: .5rem;
            font-size: .95rem;
            font-weight: 700;
            color: #a5b4fc;
        }

        /* ====== BOTONES ACCIÓN (COLORES APP) ====== */
        .btn-buy {
            background: linear-gradient(135deg,#6366f1,#8b5cf6);
            padding: 8px 20px;
            color: #f9fafb;
            font-weight: 700;
            border-radius: 999px;
            white-space: nowrap;
            transition: background .2s, box-shadow .2s, transform .1s, filter .15s;
            font-size: .85rem;
            border: none;
            text-align: center;
        }
        .btn-buy:hover {
            filter: brightness(1.08);
            box-shadow: 0 14px 34px rgba(99,102,241,.6);
            transform: translateY(-1px);
        }

        .btn-more {
            border-radius: 999px;
            padding: 8px 20px;
            font-weight: 600;
            color: #e5e7eb;
            margin-top: 8px;
            display: inline-block;
            transition: border-color .2s, background .2s, color .2s, transform .1s;
            white-space: nowrap;
            font-size: .8rem;
            border: 1px solid rgba(148,163,184,.6);
            background: rgba(15,23,42,.9);
            text-align: center;
        }
        .btn-more:hover {
            border-color: #e5e7eb;
            background: rgba(30,64,175,.65);
            transform: translateY(-1px);
        }

        .low-stock {
            background: #f97316;
            color: white;
            padding: 2px 8px;
            border-radius: 999px;
            font-size: .7rem;
            font-weight: 700;
            display: inline-block;
            margin-top: .4rem;
        }

        .status-pill {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 999px;
            font-size: .7rem;
            font-weight: 600;
            margin-left: .3rem;
            text-transform: uppercase;
            letter-spacing: .06em;
        }
        .status-pill.pub {
            background: rgba(34,197,94,.12);
            color: #4ade80;
        }
        .status-pill.borr {
            background: rgba(148,163,184,.18);
            color: #e5e7eb;
        }
    </style>
</head>
<body class="text-white font-sans">
<%@ include file="../Includes/nav_base.jspf" %>

<main class="max-w-6xl mx-auto px-5 py-10">
    <!-- HERO COMERCIAL -->
    <section class="lp-hero">
        <div class="lp-hero-bg"></div>
        <div class="lp-hero-gradient"></div>
        <div class="lp-hero-content">
            <span class="lp-hero-kicker">Vive la noche</span>
            <h1 class="lp-hero-title">Encuentra tu próximo evento en LivePass Buga</h1>
            <p class="lp-hero-sub">
                Conciertos, fiestas electrónicas, ferias, shows y más. 
                Compra tus entradas en segundos y recibe tus tickets digitales al instante.
            </p>
            <div class="lp-hero-tags">
                <span class="lp-pill">✨ Eventos verificados</span>
                <span class="lp-pill">🎫 Tickets digitales</span>
                <span class="lp-pill">🔥 Preventas exclusivas</span>
            </div>
        </div>
    </section>

    <!-- TIRA DE CATEGORÍAS CON IMÁGENES -->
    <section class="lp-strip">
        <div class="lp-strip-card">
            <div class="lp-strip-img"
                 style="background-image:url('https://images.unsplash.com/photo-1506157786151-b8491531f063?auto=format&fit=crop&w=800&q=70');"></div>
            <div class="lp-strip-overlay">
                <span class="lp-strip-title">Conciertos</span>
                <span class="lp-strip-sub">Bandas en vivo y artistas invitados</span>
            </div>
        </div>
        <div class="lp-strip-card">
            <div class="lp-strip-img"
                 style="background-image:url('https://images.unsplash.com/photo-1515211876778-4b4b4cac67ff?auto=format&fit=crop&w=800&q=70');"></div>
            <div class="lp-strip-overlay">
                <span class="lp-strip-title">Fiestas & Clubs</span>
                <span class="lp-strip-sub">DJ sets, electrónica y reggaetón</span>
            </div>
        </div>
        <div class="lp-strip-card">
            <div class="lp-strip-img"
                 style="background-image:url('https://images.unsplash.com/photo-1484821582734-6c6c9f99a672?auto=format&fit=crop&w=800&q=70');"></div>
            <div class="lp-strip-overlay">
                <span class="lp-strip-title">Experiencias</span>
                <span class="lp-strip-sub">Festivales, ferias, teatro y más</span>
            </div>
        </div>
    </section>

    <%-- Ejecuta el control: carga 'events', 'page', 'totalPages', etc. --%>
    <jsp:include page="../Control/ct_explorar_eventos.jsp" />

    <%
        // ====== RECUPERAR ATRIBUTOS CON VALORES POR DEFECTO ======
        List<Event> events = (List<Event>) request.getAttribute("events");
        if (events == null) {
            events = java.util.Collections.emptyList();
        }

        Integer pageObj  = (Integer) request.getAttribute("page");
        Integer totalObj = (Integer) request.getAttribute("totalPages");

        int pageNum    = (pageObj  != null ? pageObj  : 1);
        int totalPages = (totalObj != null ? totalObj : 1);

        String qsBase = (String) request.getAttribute("qsBase");
        if (qsBase == null) qsBase = "";

        java.time.format.DateTimeFormatter df =
                java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    %>

    <!-- ==========================
         FILTROS (REDISEÑADO)
    =========================== -->
    <form method="get" action="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp"
          class="bg-[#050816] border border-[#1f2937] rounded-2xl p-4 mb-8 shadow-xl">
        <div class="flex flex-col gap-3">
            <!-- fila superior -->
            <div class="flex flex-col md:flex-row gap-3">
                <!-- Buscar -->
                <div class="flex-1">
                    <input name="q"
                           value="<%= (String)request.getAttribute("f_q")!=null?(String)request.getAttribute("f_q"):"" %>"
                           placeholder="Buscar por título o lugar"
                           class="w-full px-4 py-2 rounded-xl bg-[#020617] border border-[#1f2937] text-sm
                                  focus:outline-none focus:ring-2 focus:ring-indigo-500/70" />
                </div>

                <!-- Género -->
                <div class="w-full md:w-48">
                    <select name="genre"
                            class="w-full ui-select px-3 py-2 rounded-xl bg-[#020617] border border-[#1f2937] text-sm
                                   focus:outline-none focus:ring-2 focus:ring-indigo-500/70">
                        <option value="">Género (todos)</option>
                        <%
                            List<String> genres = (List<String>) request.getAttribute("genres");
                            String selG = (String) request.getAttribute("f_genre");
                            if (genres!=null) for (String g: genres) {
                        %>
                        <option value="<%= g %>" <%= (selG!=null && selG.equalsIgnoreCase(g))? "selected":"" %>><%= g %></option>
                        <% } %>
                    </select>
                </div>

                <!-- Ubicación -->
                <div class="w-full md:w-48">
                    <select name="loc"
                            class="w-full ui-select px-3 py-2 rounded-xl bg-[#020617] border border-[#1f2937] text-sm
                                   focus:outline-none focus:ring-2 focus:ring-indigo-500/70">
                        <option value="">Ubicación (todas)</option>
                        <%
                            List<String> cities = (List<String>) request.getAttribute("cities");
                            String selC = (String) request.getAttribute("f_loc");
                            if (cities!=null) for (String c: cities) {
                        %>
                        <option value="<%= c %>" <%= (selC!=null && selC.equalsIgnoreCase(c))? "selected":"" %>><%= c %></option>
                        <% } %>
                    </select>
                </div>

                <!-- Precio min -->
                <div class="w-full md:w-32">
                    <input name="pmin" inputmode="numeric" pattern="[0-9]*"
                           placeholder="Precio min"
                           value="<%= (String)request.getAttribute("f_pmin")!=null?(String)request.getAttribute("f_pmin"):"" %>"
                           class="w-full px-4 py-2 rounded-xl bg-[#020617] border border-[#1f2937] text-sm
                                  focus:outline-none focus:ring-2 focus:ring-indigo-500/70" />
                </div>

                <!-- Precio max -->
                <div class="w-full md:w-32">
                    <input name="pmax" inputmode="numeric" pattern="[0-9]*"
                           placeholder="Precio máx"
                           value="<%= (String)request.getAttribute("f_pmax")!=null?(String)request.getAttribute("f_pmax"):"" %>"
                           class="w-full px-4 py-2 rounded-xl bg-[#020617] border border-[#1f2937] text-sm
                                  focus:outline-none focus:ring-2 focus:ring-indigo-500/70" />
                </div>
            </div>

            <!-- fila inferior -->
            <div class="flex flex-col sm:flex-row gap-3 justify-between">
                <div class="flex gap-3">
                    <!-- Orden -->
                    <select name="order"
                            class="ui-select px-3 py-2 rounded-xl bg-[#020617] border border-[#1f2937] text-sm
                                   focus:outline-none focus:ring-2 focus:ring-indigo-500/70">
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

                    <!-- Tamaño página -->
                    <select name="pageSize"
                            class="ui-select px-3 py-2 rounded-xl bg-[#020617] border border-[#1f2937] text-sm
                                   focus:outline-none focus:ring-2 focus:ring-indigo-500/70">
                        <%
                            int ps = 9;
                            try { ps = Integer.parseInt(request.getParameter("pageSize")); } catch(Exception ignore){}
                        %>
                        <option value="9"  <%= ps==9 ?"selected":"" %>>9</option>
                        <option value="12" <%= ps==12?"selected":"" %>>12</option>
                        <option value="24" <%= ps==24?"selected":"" %>>24</option>
                    </select>
                </div>

                <!-- Botón -->
                <div class="flex sm:justify-end">
                    <button class="btn-primary ripple px-6 py-2 rounded-full text-sm font-semibold" type="submit">
                        Filtrar
                    </button>
                </div>
            </div>
        </div>
    </form>

    <!-- ==========================
         RESULTADOS ESTILO LISTA
    =========================== -->
    <div class="space-y-4 mt-4">
        <%
            if (events!=null && !events.isEmpty()) {
                for (Event e: events) {

                    String dateStr = (e.getDateTime()!=null)
                            ? e.getDateTime().format(df)
                            : e.getDate();

                    java.time.LocalDateTime dt = e.getDateTime();
                    String day  = (dt!=null) ? String.valueOf(dt.getDayOfMonth()) : "";
                    String mon  = "";
                    String year = (dt!=null) ? String.valueOf(dt.getYear()) : "";

                    if (dt!=null) {
                        java.time.format.TextStyle ts = java.time.format.TextStyle.SHORT;
                        java.util.Locale loc = new java.util.Locale("es","ES");
                        mon = dt.getMonth().getDisplayName(ts, loc);
                    }

                    String img = (e.getImage()!=null && !e.getImage().isBlank())
                            ? e.getImage()
                            : "https://images.unsplash.com/photo-1518972559570-7cc1309f3229?auto=format&fit=crop&w=800&q=60";

                    int disp = e.getAvailability();
                    String status = e.getStatus()!=null ? e.getStatus().name() : "BORRADOR";
                    String priceFormatted = "";
                    try { priceFormatted = e.getPriceFormatted(); } catch(Exception ignore){}
        %>

        <div class="event-row">
            <!-- FECHA -->
            <div class="date-block">
                <span><%= day %></span>
                <span><%= mon %></span>
                <span><%= year %></span>
            </div>

            <!-- IMAGEN -->
            <img src="<%= img %>" alt="<%= e.getTitle() %>" class="event-img"/>

            <!-- INFO -->
            <div>
                <h3 class="info-title">
                    <%= e.getTitle() %>
                    <%
                        String sClass = "borr";
                        if ("PUBLICADO".equalsIgnoreCase(status)) sClass="pub";
                    %>
                    <span class="status-pill <%= sClass %>"><%= status %></span>
                </h3>
                <p class="info-sub">
                    <%= e.getCity()!=null?e.getCity():"" %> •
                    <%= e.getVenue()!=null?e.getVenue():"" %> •
                    <%= dateStr %>
                </p>
                <p class="info-extra">
                    🎭 <%= e.getGenre()!=null?e.getGenre():"" %>
                    <% if (e.getCategories()!=null && !e.getCategories().isBlank()) { %>
                    • <%= e.getCategories() %>
                    <% } %>
                </p>
                <% if (priceFormatted != null && !priceFormatted.isBlank()) { %>
                    <p class="info-price">Desde <%= priceFormatted %></p>
                <% } %>

                <% if (disp > 0 && disp <= 15) { %>
                    <span class="low-stock">Quedan <%= disp %> tickets</span>
                <% } %>
            </div>

            <!-- BOTONES -->
            <div class="flex flex-col items-end gap-1">
                <a class="btn-buy"
                   href="<%= request.getContextPath() %>/Vista/Checkout.jsp?eventId=<%= e.getId() %>&qty=1">
                    Comprar ticket
                </a>
                <a class="btn-more"
                   href="<%= request.getContextPath() %>/Vista/EventoDetalle.jsp?id=<%= e.getId() %>">
                    Ver detalles
                </a>
            </div>
        </div>

        <%
                }
            } else {
        %>
        <div class="glass ring rounded-2xl p-8 text-center text-white/70">
            No hay eventos que coincidan con los filtros.
        </div>
        <% } %>
    </div>

    <!-- ==========================
         PAGINACIÓN
    =========================== -->
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
    // efecto ripple para botones .ripple
    (function(){
        document.querySelectorAll('.ripple').forEach(function(btn){
            btn.addEventListener('click', function(e){
                const r = this.getBoundingClientRect();
                const s = document.createElement('span');
                const z = Math.max(r.width, r.height);
                s.style.width = s.style.height = z + 'px';
                s.style.left = (e.clientX - r.left - z/2) + 'px';
                s.style.top  = (e.clientY - r.top  - z/2) + 'px';
                s.className  = 'ripple-effect';
                this.appendChild(s);
                setTimeout(function(){ s.remove(); }, 600);
            });
        });
    })();
</script>
</body>
</html>
