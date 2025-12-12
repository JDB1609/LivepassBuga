<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.EventDAO, utils.Event" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.NumberFormat" %>

<%
    // --- Parámetro ---
    int eventId = 0;
    try { eventId = Integer.parseInt(request.getParameter("id")); } catch(Exception ignore){}
    if (eventId <= 0) {
        response.sendRedirect(request.getContextPath()+"/Vista/PaginaPrincipal.jsp");
        return;
    }

    // --- Cargar evento ---
    EventDAO dao = new EventDAO();
    Event ev = dao.findById(eventId).orElse(null);
    if (ev == null) {
        response.sendRedirect(request.getContextPath()+"/Vista/PaginaPrincipal.jsp");
        return;
    }

    // --- ZONAS / TICKET_TYPES DEL EVENTO ---
    List<EventDAO.EventZone> zones = dao.listZonesByEvent(ev.getId());
    NumberFormat curCo = NumberFormat.getCurrencyInstance(new java.util.Locale("es","CO"));

    // --- Presentación general ---
    DateTimeFormatter df = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    String dateStr = (ev.getDateTime()!=null) ? ev.getDateTime().format(df) : ev.getDate();

    String st = (ev.getStatus()!=null ? ev.getStatus().name() : "BORRADOR");
    String pill =
       "PUBLICADO".equalsIgnoreCase(st)  ? "bg-emerald-500/20 text-emerald-200" :
       "FINALIZADO".equalsIgnoreCase(st) ? "bg-white/15 text-white/80"         :
                                           "bg-yellow-500/20 text-yellow-200";

    int cap  = Math.max(0, ev.getCapacity());
    int sold = Math.max(0, ev.getSold());
    int disp = Math.max(0, cap - sold);
    int prog = (cap>0) ? (int)Math.round((sold*100.0)/cap) : 0;
    if (prog>100) prog=100;

    boolean publicado = "PUBLICADO".equalsIgnoreCase(st);
    boolean agotado   = (cap > 0 && disp == 0);

    String ctx   = request.getContextPath();
    boolean logged = (session.getAttribute("userId") != null);

    String baseBuy = logged
        ? (ctx + "/Vista/Checkout.jsp?eventId=" + ev.getId() + "&qty=")  // fallback genérico
        : (ctx + "/Vista/Login.jsp");

    String imgMain = (ev.getImage()!=null && !ev.getImage().isBlank())
        ? ev.getImage()
        : "https://images.unsplash.com/photo-1518972559570-7cc1309f3229?auto=format&fit=crop&w=1600&q=80";

    String desc = (ev.getDescription()!=null && !ev.getDescription().isBlank())
        ? ev.getDescription()
        : "Disfruta una noche única con un show en vivo, sonido de alta calidad y una producción pensada para el público de LivePass Buga.";

    String priceFormatted = "";
    try { priceFormatted = ev.getPriceFormatted(); } catch(Exception ignore){}

    String mapQuery = ( (ev.getVenue()!=null?ev.getVenue()+" ": "") + (ev.getCity()!=null?ev.getCity():"") );
    String mapUrl   = "https://www.google.com/maps?q=" + URLEncoder.encode(mapQuery, "UTF-8") + "&output=embed";
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="../Includes/head_base.jspf" %>
    <title><%= ev.getTitle()!=null? ev.getTitle() : "Evento" %> — Detalle</title>

    <style>
        body{background:#020617}

        .lp-card{
            background:#0b1120;
            border-radius:18px;
            border:1px solid rgba(148,163,184,.28);
            box-shadow:0 18px 55px rgba(0,0,0,.7);
        }
        .lp-card-soft{
            background:linear-gradient(180deg,rgba(15,23,42,.96),rgba(15,23,42,.9));
            border-radius:18px;
            border:1px solid rgba(30,64,175,.55);
            box-shadow:0 18px 55px rgba(0,0,0,.7);
        }

        .lp-hero-wrap{position:relative;border-radius:22px;overflow:hidden;}
        .lp-hero-img{
            width:100%;height:260px;
            object-fit:cover;object-position:center;
        }
        @media(min-width:1024px){
            .lp-hero-img{height:320px;}
        }
        .lp-hero-overlay{
            position:absolute;inset:0;
            background:linear-gradient(to top,#020617 0%,rgba(2,6,23,.2) 45%,transparent 100%);
        }
        .lp-hero-content{
            position:absolute;left:0;right:0;bottom:0;
            padding:18px 20px 20px;
        }

        .chip{
            display:inline-flex;align-items:center;gap:.45rem;
            border-radius:9999px;padding:.38rem .8rem;
            border:1px solid rgba(148,163,184,.7);
            background:rgba(15,23,42,.85);
            font-size:.75rem;font-weight:600;
        }

        .lp-zone-card{
            background:radial-gradient(circle at top left,#1d4ed833,#020617);
            border-radius:16px;
            border:1px solid rgba(148,163,184,.5);
            padding:10px 12px;
            display:flex;align-items:center;justify-content:space-between;gap:10px;
        }
        .lp-zone-pill{
            font-size:.7rem;font-weight:700;
            padding:2px 8px;border-radius:9999px;
            background:rgba(15,23,42,.9);border:1px solid rgba(148,163,184,.5);
        }
        .lp-btn-buy{
            background:linear-gradient(135deg,#6366f1,#8b5cf6);
            padding:7px 16px;border-radius:9999px;
            font-size:.8rem;font-weight:700;
            color:#f9fafb;white-space:nowrap;
            display:inline-flex;align-items:center;gap:.3rem;
        }
        .lp-btn-buy:hover{
            filter:brightness(1.08);
        }
        .lp-btn-ghost{
            padding:7px 14px;border-radius:9999px;
            border:1px solid rgba(148,163,184,.6);
            background:rgba(15,23,42,.9);
            font-size:.78rem;font-weight:600;
        }

        .bar-bg{height:8px;border-radius:9999px;background:rgba(148,163,184,.25);}
        .bar-fg{height:8px;border-radius:9999px;background:#22c55e;}

        .seating-img{
            width:100%;
            max-width:360px;
            margin:0 auto;
            display:block;
        }

        @media(max-width:640px){
            .sticky-cta{
                position:sticky;bottom:0;z-index:30;
                background:linear-gradient(180deg,rgba(15,23,42,0),#020617 30%,#020617);
            }
        }
    </style>
</head>
<body class="text-white font-sans">
<%@ include file="../Includes/nav_base.jspf" %>

<div class="max-w-6xl mx-auto px-4 lg:px-5 pb-10 pt-6">

    <!-- HERO -->
    <section class="lp-hero-wrap mb-6">
        <img src="<%= imgMain %>" alt="<%= ev.getTitle() %>" class="lp-hero-img" />
        <div class="lp-hero-overlay"></div>

        <div class="lp-hero-content">
            <div class="flex items-center justify-between gap-3">
                <div>
                    <p class="text-xs tracking-[0.18em] uppercase text-indigo-300 font-semibold">
                        LivePass Buga · Evento destacado
                    </p>
                    <h1 class="text-2xl md:text-3xl lg:text-4xl font-extrabold mt-1">
                        <%= ev.getTitle()!=null?ev.getTitle():"(sin título)" %>
                    </h1>
                    <div class="mt-2 flex flex-wrap gap-2 text-xs md:text-[0.78rem]">
                        <span class="chip">📅 <%= dateStr %></span>
                        <span class="chip">
                            📍 <%= ev.getVenue()!=null?ev.getVenue():"" %>
                            <% if (ev.getCity()!=null && !ev.getCity().trim().isEmpty()) { %>
                                · <%= ev.getCity() %>
                            <% } %>
                        </span>
                        <% if (ev.getGenre()!=null && !ev.getGenre().trim().isEmpty()) { %>
                            <span class="chip">🎵 <%= ev.getGenre() %></span>
                        <% } %>
                    </div>
                </div>
                <div class="hidden md:flex flex-col items-end gap-2">
                    <% if (priceFormatted!=null && !priceFormatted.isBlank()) { %>
                        <span class="text-[0.7rem] text-white/70 uppercase tracking-[0.16em]">Desde</span>
                        <span class="text-2xl font-extrabold"><%= priceFormatted %></span>
                    <% } %>
                    <span class="px-2.5 py-1 rounded-full text-[0.65rem] font-bold <%= pill %>">
                        <%= st %>
                    </span>
                </div>
            </div>
        </div>
    </section>

    <!-- BLOQUE ARTISTA / DESCRIPCIÓN PRINCIPAL -->
    <section class="grid md:grid-cols-3 gap-5 mb-6">
        <div class="md:col-span-1">
            <div class="lp-card overflow-hidden">
                <img src="<%= imgMain %>" alt="<%= ev.getTitle() %>"
                     class="w-full h-64 object-cover object-center" />
            </div>
        </div>

        <div class="md:col-span-2">
            <div class="lp-card p-6 space-y-3">
                <h2 class="text-xl font-extrabold mb-1">
                    <%= ev.getTitle()!=null?ev.getTitle():"Artista / Show" %>
                </h2>
                <p class="text-sm leading-relaxed text-white/75">
                    <%= desc %>
                </p>

                <% if (cap>0) { %>
                    <div class="mt-3">
                        <div class="flex justify-between text-xs text-white/65 mb-1">
                            <span>Disponibilidad general</span>
                            <span><%= disp %> tickets restantes</span>
                        </div>
                        <div class="bar-bg">
                            <div class="bar-fg" style="width:<%= prog %>%"></div>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    </section>

    <!-- FILA PLAYLIST / MAPA / FOTO -->
    <section class="grid lg:grid-cols-3 gap-5 mb-10">
        <!-- Playlist -->
        <div class="lp-card-soft p-4 flex flex-col gap-3">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-xs text-amber-300 font-semibold uppercase tracking-[0.16em]">
                        Playlist oficial
                    </p>
                    <p class="text-sm text-white/80">Calienta motores antes del evento</p>
                </div>
            </div>
            <div class="mt-2 rounded-xl overflow-hidden bg-black/60 aspect-video flex items-center justify-center text-xs text-white/60">
                (Embebe aquí tu widget de Spotify / YouTube)
            </div>
        </div>

        <!-- Mapa -->
        <div class="lp-card p-4 flex flex-col gap-2">
            <p class="text-xs font-semibold text-sky-300 uppercase tracking-[0.16em]">
                Mapa
            </p>
            <p class="text-sm text-white/80">
                <%= mapQuery!=null && !mapQuery.isBlank() ? mapQuery : "Ubicación del evento" %>
            </p>
            <div class="mt-2 rounded-xl overflow-hidden bg-black/60 aspect-video">
                <iframe src="<%= mapUrl %>" class="w-full h-full border-0" loading="lazy"
                        referrerpolicy="no-referrer-when-downgrade"></iframe>
            </div>
        </div>

        <!-- Imagen adicional -->
        <div class="lp-card-soft p-4 flex flex-col gap-2">
            <p class="text-xs font-semibold text-indigo-300 uppercase tracking-[0.16em]">
                Experiencia LivePass
            </p>
            <p class="text-sm text-white/80">
                Zona de barras, experiencias y momentos para compartir antes y después del show.
            </p>
            <img src="https://th.bing.com/th/id/R.030be5882079eb876df121bbdfbbd5fe?rik=uKosciQ4J1q7eQ&pid=ImgRaw&r=0"
                 alt="Experiencia" class="mt-2 rounded-xl object-cover h-40 w-full">
        </div>
    </section>

    <!-- MAPA Y UBICACIÓN / ZONAS -->
    <section class="mb-8">
        <h2 class="text-center text-xl md:text-2xl font-extrabold mb-1">Mapa y Ubicación</h2>
        <p class="text-center text-sm text-white/65 mb-6">
            Elige tu sector favorito y asegura tus entradas antes de que se agoten.
        </p>

        <div class="grid lg:grid-cols-2 gap-6">
            <!-- MAPA DE SECTORES -->
            <div class="lp-card p-5 flex flex-col items-center justify-center">
                <img src="https://th.bing.com/th/id/R.6e63a8e3ff5b22819bec547e1aeb78df?rik=C2eapoJm9tEwnw&riu=http%3a%2f%2fconsorcioiee.com%2fwp-content%2fuploads%2f2022%2f08%2filuminacion-auditorios-1.jpg&ehk=cknlrS%2bM4Sx7rhqDTHLgFzfal0wOY6BDj90AYH6maNg%3d&risl=&pid=ImgRaw&r=0"
                     alt="Mapa de sectores" class="seating-img rounded-2xl object-cover">
                <p class="mt-3 text-xs text-white/60 text-center">
                    Referencia de sectores. Personaliza esta imagen por el mapa de tu evento.
                </p>
            </div>

            <!-- ZONAS Y TICKETS DESDE BD -->
            <div class="space-y-3">
                <%
                    if (zones != null && !zones.isEmpty()) {
                        for (EventDAO.EventZone z : zones) {
                            int zCap  = Math.max(0, z.getCapacity());
                            int zSold = Math.max(0, z.getSold());
                            int zDisp = Math.max(0, zCap - zSold);
                            String zPrice = curCo.format(z.getPrice());

                            boolean zAgotado = (zCap > 0 && zDisp == 0);
                            String availText = zCap > 0
                                    ? (zAgotado ? "Agotado" : ("Quedan " + zDisp + " tickets"))
                                    : "Disponibilidad limitada";

                            String buyHref = logged
                                    ? (ctx + "/Vista/Checkout.jsp?eventId=" + ev.getId()
                                       + "&ticketTypeId=" + z.getId() + "&qty=1")
                                    : baseBuy;
                %>
                <div class="lp-zone-card">
                    <div>
                        <div class="flex items-center gap-2">
                            <span class="text-sm font-bold"><%= z.getName() %></span>
                            <span class="lp-zone-pill">Sector</span>
                        </div>
                        <div class="text-xs text-white/65 mt-1">
                            Aforo: <%= zCap %> • Vendidos: <%= zSold %>
                        </div>
                        <div class="mt-1 text-xs <%= zAgotado ? "text-rose-300" : "text-emerald-300" %>">
                            <%= availText %>
                        </div>
                    </div>
                    <div class="text-right flex flex-col items-end gap-1">
                        <span class="text-[0.7rem] text-white/60 uppercase tracking-[0.14em]">Desde</span>
                        <span class="text-sm font-extrabold"><%= zPrice %></span>

                        <% if (publicado && !zAgotado) { %>
                            <a href="<%= buyHref %>" class="lp-btn-buy">
                                Comprar
                            </a>
                        <% } else { %>
                            <button class="lp-btn-ghost text-white/50 cursor-not-allowed" disabled>
                                No disponible
                            </button>
                        <% } %>
                    </div>
                </div>
                <%
                        } // end for
                    } else {
                %>
                <div class="lp-card p-4 text-sm text-white/70">
                    Aún no se han configurado sectores para este evento.
                </div>
                <% } %>
            </div>
        </div>
    </section>

    <!-- CTA MÓVIL PEGADO ABAJO -->
    <div class="sticky-cta sm:hidden pt-3">
        <div class="lp-card-soft p-3 flex items-center justify-between gap-3">
            <div>
                <div class="text-[0.65rem] text-white/60 uppercase tracking-[0.18em]">Desde</div>
                <div class="text-lg font-extrabold"><%= priceFormatted %></div>
            </div>
            <% if (publicado && !agotado) { %>
                <a href="<%= logged ? (baseBuy + 1) : baseBuy %>" class="lp-btn-buy">
                    Comprar entradas
                </a>
            <% } else { %>
                <button class="lp-btn-ghost text-white/50 cursor-not-allowed" disabled>No disponible</button>
            <% } %>
        </div>
    </div>
</div>

</body>
</html>
