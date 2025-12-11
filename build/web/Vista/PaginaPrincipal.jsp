<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.EventDAO" %>
<%@ page import="utils.Event" %>
<%@ page import="java.util.List" %>

<%
    // ==========================
    // SESIÓN
    // ==========================
    Integer userId   = (Integer) session.getAttribute("userId");
    String userName  = (String) session.getAttribute("name");
    boolean loggedIn = (userId != null);
%>

<%
    // ==========================
    // CARGAR EVENTOS DESTACADOS
    // ==========================
    List<Event> featured = null;
    try {
        EventDAO dao = new EventDAO();
        featured = dao.listFeatured(10);
    } catch (Exception ex) {
        ex.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>LivePassBuga - Página Principal</title>

    <!-- Tailwind -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- Iconos Material -->
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

    <!-- CSS general -->
    <link rel="stylesheet" href="../Styles/estilos.css">

    <style>
        body { background-color:#0A0C14; color:white; }

        /* NAV */
        #lp-nav .nav-link{
            position:relative;
            font-weight:600;
            font-size:.9rem;
            color:rgba(248,250,252,.78);
        }
        #lp-nav .nav-link:hover{
            color:#ffffff;
        }
        #lp-nav .nav-link::after{
            content:"";
            position:absolute;
            left:0; right:0; bottom:-6px;
            height:2px;
            background:linear-gradient(90deg,#5469D5,#00E0C6);
            transform:scaleX(0);
            transform-origin:left;
            transition:transform .25s ease;
        }
        #lp-nav .nav-link:hover::after{
            transform:scaleX(1);
        }

        .brand-wrapper{ display:flex; align-items:center; gap:.6rem; }
        .brand-logo{
            width:110px;
            filter:drop-shadow(0 10px 25px rgba(0,0,0,.65));
            transition:.18s ease;
        }
        .brand-wrapper:hover .brand-logo{
            transform:translateY(-1px) scale(1.06);
        }
        .brand-sub{
            font-size:.68rem; letter-spacing:.24em; opacity:.85;
        }

        .btn-outline{
            border-radius:.75rem; padding:.45rem 1.3rem;
            border:1px solid #00E0C6; color:#00E0C6;
            font-weight:600; font-size:.85rem;
            transition:all .18s ease;
        }
        .btn-outline:hover{
            background:#00E0C6;
            color:#020617;
        }
        .btn-solid{
            border-radius:.75rem;
            padding:.45rem 1.3rem;
            background:#5469D5;
            font-weight:600;
            font-size:.85rem;
            transition:all .18s ease;
        }
        .btn-solid:hover{
            background:#4256c7;
        }

        .hamburger{
            width:34px; height:30px;
            display:flex; flex-direction:column; gap:5px;
            justify-content:center;
            cursor:pointer;
        }
        .hamburger span{
            height:2px; background:white; border-radius:99px;
            transition:transform .18s ease, opacity .18s ease;
        }
        .hamburger.open span:nth-child(1){ transform:rotate(45deg) translate(5px,5px); }
        .hamburger.open span:nth-child(2){ opacity:0; }
        .hamburger.open span:nth-child(3){ transform:rotate(-45deg) translate(6px,-6px); }

        /* Ocultar scrollbar horizontal del carrusel */
        .no-scrollbar::-webkit-scrollbar{
            display:none;
        }
        .no-scrollbar{
            -ms-overflow-style:none;  /* IE / Edge */
            scrollbar-width:none;     /* Firefox */
        }

        /* ===========================
           BOTÓN FLOTANTE SOPORTE
        =========================== */
        .lp-support-btn{
            position:fixed;
            right:1.5rem;
            bottom:1.5rem;
            z-index:60;
            display:inline-flex;
            align-items:center;
            gap:.45rem;
            padding:.55rem 1rem;
            border-radius:999px;
            border:1px solid rgba(148,163,184,.65);
            background:radial-gradient(circle at top,#111827,#020617);
            color:#e5e7eb;
            font-size:.8rem;
            font-weight:600;
            box-shadow:0 18px 40px rgba(0,0,0,.75);
            cursor:pointer;
            transition:transform .18s ease, box-shadow .18s ease, background .18s ease;
        }
        .lp-support-btn:hover{
            transform:translateY(-2px);
            box-shadow:0 24px 55px rgba(0,0,0,.9);
            background:linear-gradient(135deg,#5469D5,#00E0C6);
            color:#f9fafb;
        }
        .lp-support-badge{
            font-size:.65rem;
            padding:.09rem .45rem;
            border-radius:999px;
            background:rgba(15,23,42,.9);
            border:1px solid rgba(148,163,184,.6);
            text-transform:uppercase;
            letter-spacing:.16em;
        }
        .lp-support-dot{
            width:8px;
            height:8px;
            border-radius:999px;
            background:#22c55e;
            box-shadow:0 0 10px rgba(34,197,94,.9);
        }

        /* Modal soporte */
        .lp-modal-backdrop{
            background:radial-gradient(circle at top,#020617ee,#020617f7);
        }
        .lp-modal-panel{
            max-width:420px;
            width:100%;
            border-radius:1.5rem;
            background:#020617;
            border:1px solid rgba(148,163,184,.35);
            box-shadow:0 30px 80px rgba(0,0,0,.95);
        }
        .lp-modal-title{
            font-size:1.1rem;
            font-weight:700;
        }
        .lp-modal-input,
        .lp-modal-textarea{
            background:rgba(15,23,42,.96);
            border-radius:0.9rem;
            border:1px solid rgba(148,163,184,.4);
            font-size:.85rem;
            transition:.2s ease;
        }
        .lp-modal-input:focus,
        .lp-modal-textarea:focus{
            outline:none;
            border-color:#6366f1;
            box-shadow:0 0 0 1px #6366f1;
            background:rgba(15,23,42,1);
        }

        @keyframes lp-modal-in{
            from{
                opacity:0;
                transform:translateY(10px) scale(.96);
            }
            to{
                opacity:1;
                transform:translateY(0) scale(1);
            }
        }
        .lp-modal-anim{
            animation:lp-modal-in .25s ease-out;
        }

        @keyframes lp-support-pulse{
            0%{ box-shadow:0 0 0 0 rgba(56,189,248,.45); }
            70%{ box-shadow:0 0 0 12px rgba(56,189,248,0); }
            100%{ box-shadow:0 0 0 0 rgba(56,189,248,0); }
        }
        .lp-support-btn--pulse{
            animation:lp-support-pulse 2.2s infinite;
        }
    </style>
</head>

<body class="bg-[#0A0C14] text-white">

<!-- =========================== NAVBAR =========================== -->
<header id="lp-nav" class="sticky top-0 z-30">
    <div class="w-full border-b border-white/10 bg-[#050812]/90 backdrop-blur">
        <div class="max-w-6xl mx-auto px-4 py-3 flex items-center justify-between">

            <!-- LOGO -->
            <a href="PaginaPrincipal.jsp" class="brand-wrapper">
                <img src="../Imagenes/Livepass Buga Logo.png" class="brand-logo" alt="LivePassBuga">
                <span class="hidden sm:block brand-sub">Tickets &amp; eventos</span>
            </a>

            <!-- BOTÓN HAMBURGUESA -->
            <button id="btnMenu" class="hamburger md:hidden" aria-label="Abrir menú">
                <span></span><span></span><span></span>
            </button>

            <!-- MENÚ DESKTOP -->
            <ul class="hidden md:flex gap-8 items-center">
                <li><a href="PaginaPrincipal.jsp" class="nav-link">Inicio</a></li>
                <li><a href="ExplorarEventos.jsp" class="nav-link">Descubrir</a></li>
                <li><a href="#" class="nav-link">Categorías</a></li>
                <li><a href="Soporte.jsp" class="nav-link">Soporte</a></li>
            </ul>

            <!-- BOTONES SEGÚN SESIÓN -->
            <% if (!loggedIn) { %>
            <div class="hidden md:flex gap-3">
                <a href="Login.jsp" class="btn-outline">Ingresar</a>
                <a href="Registro.jsp" class="btn-solid">Registrarse</a>
            </div>
            <% } else { %>
            <div class="hidden md:flex gap-3 items-center">
                <span class="text-sm max-w-[140px] truncate"><%= userName %></span>
                <a href="MisTickets.jsp" class="btn-solid">Mis Tickets</a>
            </div>
            <% } %>

        </div>

        <!-- MENÚ MÓVIL -->
        <div id="mobileMenu" class="hidden md:hidden border-t border-white/10 bg-[#050812]/95">
            <div class="px-4 py-3 flex flex-col gap-2 text-sm">
                <a href="PaginaPrincipal.jsp" class="nav-link block py-1.5">Inicio</a>
                <a href="ExplorarEventos.jsp" class="nav-link block py-1.5">Descubrir</a>
                <a href="#" class="nav-link block py-1.5">Categorías</a>
                <a href="Soporte.jsp" class="nav-link block py-1.5">Soporte</a>

                <div class="h-px bg-white/10 my-2"></div>

                <% if (!loggedIn) { %>
                <a href="Login.jsp" class="btn-outline w-full text-center mt-1">Ingresar</a>
                <a href="Registro.jsp" class="btn-solid w-full text-center">Registrarse</a>
                <% } else { %>
                <span class="mt-1 text-slate-100 text-sm"><%= userName %></span>
                <a href="MisTickets.jsp" class="btn-solid w-full text-center mt-1">Mis Tickets</a>
                <% } %>
            </div>
        </div>
    </div>
</header>

<!-- ===========================
     HERO SECTION
=========================== -->
<section class="relative w-full h-[460px] md:h-[450px] mt-2 overflow-hidden">
    <!-- Fondo -->
    <img src="https://images.pexels.com/photos/1190297/pexels-photo-1190297.jpeg?auto=compress&cs=tinysrgb&w=1600"
         alt="LivePassBuga Hero"
         class="w-full h-full object-cover opacity-60">

    <!-- Degradado oscuro -->
    <div class="absolute inset-0 bg-gradient-to-t from-[#020617] via-[#020617]/40 to-transparent"></div>

    <!-- Contenido hero -->
    <div class="absolute inset-x-4 sm:inset-x-6 md:left-10 md:right-auto top-16 md:top-20 max-w-md md:max-w-xl">
        <p class="text-xs sm:text-sm mb-1 font-semibold tracking-[0.3em] uppercase text-[#00E0C6]">
            Plataforma moderna
        </p>

        <h1 class="text-2xl sm:text-3xl md:text-4xl font-extrabold leading-tight titulo">
            Compra, gestiona y valida
            <span class="block text-[#5469D5]">tickets con código QR</span>
        </h1>

        <p class="mt-2 text-[13px] sm:text-sm md:text-base text-slate-100/85">
            Experiencia sin filas, validación instantánea y seguridad total
            para eventos en Buga y el Lago Calima.
        </p>

        <!-- Barra de búsqueda -->
        <div class="mt-5 flex justify-center md:justify-start">
            <div class="flex items-center bg-white/95 rounded-xl shadow-md px-3 py-2 w-full max-w-md">
                <span class="material-icons text-gray-500 mr-2 text-base sm:text-lg">search</span>
                <input
                    type="text"
                    placeholder="Buscar eventos por artista, ciudad o lugar"
                    class="w-full outline-none text-sm sm:text-[0.9rem] bg-transparent text-slate-900 placeholder:text-slate-500">
            </div>
        </div>

        <!-- Chips -->
        <div class="mt-3 hidden sm:flex gap-2 text-[11px] text-slate-200/80">
            <span class="px-3 py-1 rounded-full bg-black/30 border border-white/10">
                Hoy en Buga
            </span>
            <span class="px-3 py-1 rounded-full bg-black/20 border border-white/10">
                Este fin de semana
            </span>
            <span class="px-3 py-1 rounded-full bg-black/20 border border-white/10">
                Lago Calima
            </span>
        </div>
    </div>

    <!-- Tarjeta lateral (desktop) -->
    <div class="hidden md:block absolute right-4 md:right-10 top-8 w-[280px] md:w-[300px]">
        <div class="rounded-2xl shadow-2xl bg-[#050816]/95 backdrop-blur border border-white/10 overflow-hidden">
            <img src="https://images.pexels.com/photos/167636/pexels-photo-167636.jpeg?auto=compress&cs=tinysrgb&w=900"
                 alt="Evento destacado"
                 class="w-full h-[180px] object-cover">

            <div class="p-4">
                <p class="text-[11px] tracking-[0.28em] uppercase text-[#00E0C6] mb-1">
                    Próximo evento
                </p>
                <h2 class="text-sm font-semibold titulo">Sunset Lake Festival</h2>
                <p class="text-[11px] text-slate-300 mt-1">
                    Line up sorpresa • Lago Calima
                </p>
                <p class="mt-2 font-semibold text-[#5469D5] text-sm">
                    $80.000 - $350.000
                </p>

                <button class="mt-3 w-full py-2 rounded-lg bg-[#5469D5] hover:bg-[#4256c7] text-sm font-semibold">
                    Reservar
                </button>
                <button class="mt-2 w-full py-2 rounded-lg border border-white/15 text-sm">
                    Ver detalles
                </button>
            </div>
        </div>
    </div>

    <!-- Panel compacto móvil -->
    <div class="md:hidden absolute inset-x-4 bottom-4">
        <div class="w-full rounded-xl shadow-lg bg-[#050816]/95 backdrop-blur p-3 flex items-center gap-3">
            <img src="https://images.pexels.com/photos/167636/pexels-photo-167636.jpeg?auto=compress&cs=tinysrgb&w=900"
                 alt="Evento móvil"
                 class="rounded-lg w-20 h-16 object-cover flex-shrink-0">

            <div class="flex-1">
                <h2 class="text-sm font-semibold titulo leading-snug">Próximo evento</h2>
                <p class="text-[11px] text-slate-300">Line up sorpresa • Lago Calima</p>
                <p class="mt-1 text-[11px] font-semibold text-[#5469D5]">$80.000 - $350.000</p>
            </div>

            <button class="px-3 py-1.5 rounded-full bg-[#5469D5] text-[11px] font-semibold whitespace-nowrap">
                Ver más
            </button>
        </div>
    </div>
</section>

<!-- ===========================
     CARRUSEL DE EVENTOS
=========================== -->
<section class="mt-10 md:mt-12 px-4 sm:px-6 md:px-10 max-w-6xl mx-auto overflow-visible">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-4 gap-3">
        <div>
            <h2 class="text-xl sm:text-2xl font-bold titulo">Popular esta semana</h2>
            <p class="text-xs sm:text-sm text-slate-300/80">
                Explora lo que más están comprando ahora mismo.
            </p>
        </div>

        <!-- Flechas desktop -->
        <div class="hidden md:flex items-center gap-2">
            <button id="arrowPrev"
                    class="w-8 h-8 rounded-full border border-slate-500/60 flex items-center justify-center text-sm bg-[#050816] hover:bg-gradient-to-r hover:from-[#5469D5] hover:to-[#00E0C6] transition">
                <span class="material-icons text-[18px]">chevron_left</span>
            </button>
            <button id="arrowNext"
                    class="w-8 h-8 rounded-full border border-slate-500/60 flex items-center justify-center text-sm bg-[#050816] hover:bg-gradient-to-r hover:from-[#5469D5] hover:to-[#00E0C6] transition">
                <span class="material-icons text-[18px]">chevron_right</span>
            </button>
        </div>
    </div>

    <!-- Track carrusel -->
    <div class="relative">
        <div id="carouselCards"
             class="flex gap-3 sm:gap-4 md:gap-5 overflow-x-auto scroll-smooth no-scrollbar pb-2">

            <%
                if (featured != null && !featured.isEmpty()) {
                    java.time.format.DateTimeFormatter DT_FMT =
                            java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
                    java.text.NumberFormat NF_CO =
                            java.text.NumberFormat.getCurrencyInstance(new java.util.Locale("es","CO"));

                    for (Event ev : featured) {

                        String image = (ev.getImage() != null && !ev.getImage().isEmpty())
                                ? ev.getImage()
                                : "https://images.pexels.com/photos/1190297/pexels-photo-1190297.jpeg?auto=compress&cs=tinysrgb&w=800";

                        String ciudad = ev.getCity() != null ? ev.getCity() : "";
                        String venue  = ev.getVenue() != null ? ev.getVenue() : "";
                        String titulo = ev.getTitle() != null ? ev.getTitle() : "Evento sin título";

                        String fecha  = "";
                        if (ev.getDateTime() != null) {
                            fecha = ev.getDateTime().format(DT_FMT);
                        }

                        String precio = "";
                        if (ev.getPrice() != null) {
                            precio = NF_CO.format(ev.getPrice());
                        }

                        String categoria = ev.getCategories() != null ? ev.getCategories() : "EVENTO";
            %>

            <!-- Card evento -->
            <article class="relative min-w-[240px] max-w-[260px] rounded-2xl bg-[#050816] border border-white/5 overflow-hidden shadow-xl flex-shrink-0 hover:-translate-y-2 hover:shadow-2xl transition-transform duration-300">
                <div class="relative h-40">
                    <img src="<%= image %>"
                         alt="<%= ev.getImageAlt() != null ? ev.getImageAlt() : titulo %>"
                         class="w-full h-full object-cover">
                    <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent"></div>

                    <span class="absolute top-2 left-2 px-2.5 py-1 rounded-full text-[10px] font-semibold tracking-[0.18em] uppercase bg-black/60 text-[#00E0C6]">
                        <%= categoria %>
                    </span>
                </div>

                <div class="p-3.5">
                    <p class="text-[11px] uppercase tracking-[0.2em] text-slate-400 mb-1">
                        <%= ciudad %><% if (!ciudad.isEmpty() && !venue.isEmpty()) { %> • <% } %><%= venue %>
                    </p>
                    <h3 class="text-sm font-semibold titulo line-clamp-2 mb-1.5"><%= titulo %></h3>
                    <p class="text-[11px] text-slate-300 mb-1"><%= fecha %></p>

                    <% if (!precio.isEmpty()) { %>
                    <p class="text-[12px] font-semibold text-[#5469D5] mb-3">
                        Desde <%= precio %>
                    </p>
                    <% } %>

                    <div class="flex items-center justify-between">
                        <a href="EventoDetalle.jsp?id=<%= ev.getId() %>"
                           class="text-[11px] text-[#00E0C6] hover:text-[#7DEBF0] underline decoration-dotted">
                            Ver detalles
                        </a>
                        <a href="EventoDetalle.jsp?id=<%= ev.getId() %>"
                           class="px-3 py-1.5 rounded-full bg-gradient-to-r from-[#5469D5] to-[#00E0C6] text-[11px] font-semibold">
                            Comprar
                        </a>
                    </div>
                </div>
            </article>

            <%
                    }
                } else {
            %>

            <!-- Fallback sin eventos -->
            <article class="min-w-[260px] max-w-xs rounded-2xl bg-[#050816] border border-white/5 overflow-hidden shadow-xl flex-shrink-0">
                <div class="relative h-40">
                    <img src="https://images.pexels.com/photos/1190297/pexels-photo-1190297.jpeg?auto=compress&cs=tinysrgb&w=800"
                         alt="Sin eventos"
                         class="w-full h-full object-cover">
                    <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent"></div>
                </div>
                <div class="p-3.5">
                    <p class="text-[11px] uppercase tracking-[0.2em] text-slate-400 mb-1">
                        Sin eventos
                    </p>
                    <h3 class="text-sm font-semibold titulo mb-1.5">
                        Aún no hay eventos publicados
                    </h3>
                    <p class="text-[11px] text-slate-300">
                        Cuando publiques tus eventos, aparecerán aquí automáticamente.
                    </p>
                </div>
            </article>

            <%
                }
            %>
        </div>
    </div>

    <!-- Flechas móviles -->
    <div class="flex md:hidden justify-end gap-2 mt-2">
        <button id="arrowPrevMobile"
                class="w-8 h-8 rounded-full border border-slate-500/60 flex items-center justify-center text-sm bg-[#050816]">
            <span class="material-icons text-[18px]">chevron_left</span>
        </button>
        <button id="arrowNextMobile"
                class="w-8 h-8 rounded-full border border-slate-500/60 flex items-center justify-center text-sm bg-[#050816]">
            <span class="material-icons text-[18px]">chevron_right</span>
        </button>
    </div>
</section>

<!-- ===========================
     PRÓXIMOS LANZAMIENTOS
=========================== -->
<section class="mt-12 md:mt-16 px-4 sm:px-6 md:px-10 max-w-6xl mx-auto">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-4 gap-3">
        <div>
            <p class="pill bg-[#111827] text-[#9ca3af] mb-2 text-[11px] sm:text-xs">Nuevos en LivePassBuga</p>
            <h2 class="section-title titulo text-xl sm:text-2xl">Próximos lanzamientos</h2>
            <p class="text-xs sm:text-sm text-slate-300/80">
                Asegura tu lugar antes de que se agoten los cupos.
            </p>
        </div>

        <button class="hidden md:inline-flex items-center gap-2 px-4 py-2 rounded-full text-xs font-semibold
                       bg-gradient-to-r from-[#5469D5] to-[#00E0C6]">
            Ver todos los eventos
            <span class="material-icons text-xs">arrow_forward</span>
        </button>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">

        <!-- Card estática 1 -->
        <div class="rounded-2xl overflow-hidden bg-[#050816] border border-white/5 shadow-xl hover:-translate-y-2 transition">
            <img src="https://images.pexels.com/photos/167636/pexels-photo-167636.jpeg?auto=compress&cs=tinysrgb&w=1200"
                 class="w-full h-40 sm:h-44 object-cover" alt="Concierto urbano">
            <div class="p-4">
                <p class="text-[11px] tracking-[0.2em] uppercase text-[#00E0C6] mb-1">
                    Buga · Coliseo
                </p>
                <h3 class="font-semibold titulo mb-1 text-sm sm:text-base">Urbano Night Fest</h3>
                <p class="text-xs text-slate-300 mb-2">
                    Line up con artistas urbanos invitados, visuales y show de luces.
                </p>
                <div class="flex items-center justify-between text-xs mt-2">
                    <span class="font-semibold text-[#5469D5]">Desde $80.000</span>
                    <button class="px-3 py-1 rounded-full bg-white text-black text-[11px] font-semibold">
                        Comprar ahora
                    </button>
                </div>
            </div>
        </div>

        <!-- Card estática 2 -->
        <div class="rounded-2xl overflow-hidden bg-[#050816] border border-white/5 shadow-xl hover:-translate-y-2 transition">
            <img src="https://images.pexels.com/photos/1105666/pexels-photo-1105666.jpeg?auto=compress&cs=tinysrgb&w=1200"
                 class="w-full h-40 sm:h-44 object-cover" alt="Festival al aire libre">
            <div class="p-4">
                <p class="text-[11px] tracking-[0.2em] uppercase text-[#00E0C6] mb-1">
                    Lago Calima · Sunset
                </p>
                <h3 class="font-semibold titulo mb-1 text-sm sm:text-base">Sunset Lake Festival</h3>
                <p class="text-xs text-slate-300 mb-2">
                    DJs, food trucks y cocteles frente al atardecer del lago.
                </p>
                <div class="flex items-center justify-between text-xs mt-2">
                    <span class="font-semibold text-[#5469D5]">Desde $120.000</span>
                    <button class="px-3 py-1 rounded-full bg-white text-black text-[11px] font-semibold">
                        Comprar ahora
                    </button>
                </div>
            </div>
        </div>

        <!-- Card estática 3 -->
        <div class="rounded-2xl overflow-hidden bg-[#050816] border border-white/5 shadow-xl hover:-translate-y-2 transition">
            <img src="https://images.pexels.com/photos/7131497/pexels-photo-7131497.jpeg?auto=compress&cs=tinysrgb&w=1200"
                 class="w-full h-40 sm:h-44 object-cover" alt="Obra de teatro">
            <div class="p-4">
                <p class="text-[11px] tracking-[0.2em] uppercase text-[#00E0C6] mb-1">
                    Teatro Municipal
                </p>
                <h3 class="font-semibold titulo mb-1 text-sm sm:text-base">Noche de Stand-Up &amp; Teatro</h3>
                <p class="text-xs text-slate-300 mb-2">
                    Comedia, storytelling y una puesta en escena íntima.
                </p>
                <div class="flex items-center justify-between text-xs mt-2">
                    <span class="font-semibold text-[#5469D5]">Desde $60.000</span>
                    <button class="px-3 py-1 rounded-full bg-white text-black text-[11px] font-semibold">
                        Comprar ahora
                    </button>
                </div>
            </div>
        </div>

    </div>
</section>

<!-- ===========================
     BENEFICIOS
=========================== -->
<section class="mt-12 md:mt-16 px-4 sm:px-6 md:px-10 max-w-6xl mx-auto">
    <div class="grid md:grid-cols-2 gap-10 items-center">

        <!-- TEXTO -->
        <div>
            <p class="pill bg-[#111827] text-[#9ca3af] mb-3 text-[11px] sm:text-xs">
                Confianza para tus eventos
            </p>

            <h2 class="section-title titulo mb-3 text-xl sm:text-2xl">
                Una plataforma diseñada para organizadores y asistentes exigentes.
            </h2>

            <p class="text-xs sm:text-sm text-slate-300 mb-4">
                LivePassBuga centraliza la venta de tickets, el control de acceso y la
                información de tus asistentes en una sola plataforma, segura y rápida.
            </p>

            <ul class="space-y-3 text-xs sm:text-sm text-slate-200">
                <li class="flex gap-3">
                    <span class="material-icons text-[#00E0C6] text-base">verified</span>
                    <div>
                        <p class="font-semibold">Pagos verificados y seguros</p>
                        <p class="text-[11px] sm:text-xs text-slate-400">
                            Integración con pasarelas de pago, validación QR y reportes en tiempo real.
                        </p>
                    </div>
                </li>

                <li class="flex gap-3">
                    <span class="material-icons text-[#00E0C6] text-base">qr_code_scanner</span>
                    <div>
                        <p class="font-semibold">Check-in ultra rápido</p>
                        <p class="text-[11px] sm:text-xs text-slate-400">
                            Escanea tickets desde cualquier dispositivo y controla el aforo profesionalmente.
                        </p>
                    </div>
                </li>

                <li class="flex gap-3">
                    <span class="material-icons text-[#00E0C6] text-base">insights</span>
                    <div>
                        <p class="font-semibold">Datos que generan ventas</p>
                        <p class="text-[11px] sm:text-xs text-slate-400">
                            Estadísticas detalladas por zona, ciudad, canal de venta y tendencias.
                        </p>
                    </div>
                </li>
            </ul>
        </div>

        <!-- IMÁGENES -->
        <div class="grid grid-cols-2 gap-4">
            <div class="row-span-2 rounded-2xl overflow-hidden bg-[#050816] border border-white/5">
                <img src="https://images.pexels.com/photos/1190297/pexels-photo-1190297.jpeg?auto=compress&cs=tinysrgb&w=1200"
                     class="w-full h-full object-cover"
                     alt="Concierto">
            </div>

            <div class="rounded-2xl overflow-hidden bg-[#050816] border border-white/5">
                <img src="https://images.pexels.com/photos/6898859/pexels-photo-6898859.jpeg?auto=compress&cs=tinysrgb&w=800"
                     class="w-full h-28 sm:h-32 object-cover"
                     alt="Producción backstage">
            </div>

            <div class="rounded-2xl overflow-hidden bg-gradient-to-br from-[#111827] to-[#020617] border border-white/10 p-4 flex flex-col justify-between">
                <div>
                    <p class="text-[11px] sm:text-xs text-[#9ca3af] mb-1">Organizadores</p>
                    <p class="font-semibold titulo text-sm sm:text-base mb-2">Dashboard de ventas en vivo</p>
                    <p class="text-[11px] sm:text-xs text-slate-400">
                        Mira cuántas entradas se han vendido por sector, día y canal.
                    </p>
                </div>
                <button class="mt-4 px-3 py-2 text-[11px] rounded-full border border-[#00E0C6] text-[#00E0C6] hover:bg-[#00E0C6] hover:text-[#020617] transition">
                    Solicitar demo para organizadores
                </button>
            </div>
        </div>

    </div>
</section>

<!-- ===========================
     CATEGORÍAS DESTACADAS
=========================== -->
<section class="mt-12 md:mt-16 px-4 sm:px-6 md:px-10 max-w-6xl mx-auto">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-5">
        <div>
            <p class="pill bg-[#111827] text-[#9ca3af] mb-2 text-[11px] sm:text-xs">Encuentra tu plan</p>
            <h2 class="section-title titulo text-xl sm:text-2xl">Explora por categoría</h2>
        </div>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">

        <!-- Categoría 1 -->
        <div class="relative overflow-hidden rounded-2xl bg-[#050816] border border-white/5 group">
            <img src="https://images.pexels.com/photos/3374222/pexels-photo-3374222.jpeg?auto=compress&cs=tinysrgb&w=1200"
                 class="w-full h-36 sm:h-40 object-cover opacity-80 group-hover:scale-105 transition"
                 alt="Conciertos">
            <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent"></div>

            <div class="absolute bottom-3 left-3 right-3">
                <p class="text-[11px] uppercase tracking-[0.2em] text-[#9ca3af]">Vive la música</p>
                <h3 class="font-semibold titulo text-sm sm:text-base">Conciertos &amp; Festivales</h3>
            </div>
        </div>

        <!-- Categoría 2 -->
        <div class="relative overflow-hidden rounded-2xl bg-[#050816] border border-white/5 group">
            <img src="https://images.pexels.com/photos/1047440/pexels-photo-1047440.jpeg?auto=compress&cs=tinysrgb&w=1200"
                 class="w-full h-36 sm:h-40 object-cover opacity-80 group-hover:scale-105 transition"
                 alt="Electrónica">
            <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent"></div>

            <div class="absolute bottom-3 left-3 right-3">
                <p class="text-[11px] uppercase tracking-[0.2em] text-[#9ca3af]">Atardeceres &amp; clubs</p>
                <h3 class="font-semibold titulo text-sm sm:text-base">Electrónica &amp; Sunsets</h3>
            </div>
        </div>

        <!-- Categoría 3 -->
        <div class="relative overflow-hidden rounded-2xl bg-[#050816] border border-white/5 group">
            <img src="https://images.pexels.com/photos/2253879/pexels-photo-2253879.jpeg?auto=compress&cs=tinysrgb&w=1200"
                 class="w-full h-36 sm:h-40 object-cover opacity-80 group-hover:scale-105 transition"
                 alt="Eventos familiares">
            <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent"></div>

            <div class="absolute bottom-3 left-3 right-3">
                <p class="text-[11px] uppercase tracking-[0.2em] text-[#9ca3af]">Niños &amp; familias</p>
                <h3 class="font-semibold titulo text-sm sm:text-base">Eventos familiares</h3>
            </div>
        </div>

        <!-- Categoría 4 -->
        <div class="relative overflow-hidden rounded-2xl bg-[#050816] border border-white/5 group">
            <img src="https://images.pexels.com/photos/1181395/pexels-photo-1181395.jpeg?auto=compress&cs=tinysrgb&w=1200"
                 class="w-full h-36 sm:h-40 object-cover opacity-80 group-hover:scale-105 transition"
                 alt="Corporativos">
            <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent"></div>

            <div class="absolute bottom-3 left-3 right-3">
                <p class="text-[11px] uppercase tracking-[0.2em] text-[#9ca3af]">Empresas &amp; marcas</p>
                <h3 class="font-semibold titulo text-sm sm:text-base">Corporativos &amp; Conferencias</h3>
            </div>
        </div>

    </div>
</section>

<!-- ===========================
     BOTÓN FLOTANTE DE SOPORTE
=========================== -->
<button id="btnSoporte"
        type="button"
        class="lp-support-btn lp-support-btn--pulse">
    <span class="lp-support-dot"></span>
    <span>Soporte &amp; PQRS</span>
    <span class="lp-support-badge hidden sm:inline">Ayuda</span>
</button>

<!-- ===========================
     MODAL SOPORTE / PQRS
=========================== -->
<div id="modalSoporte"
     class="fixed inset-0 z-50 hidden items-center justify-center lp-modal-backdrop px-4 sm:px-6">

    <!-- Cerrar por fondo -->
    <div class="absolute inset-0" id="modalSoporteBackdrop"></div>

    <!-- Panel -->
    <div class="lp-modal-panel relative p-5 sm:p-6 lp-modal-anim">
        <!-- Header -->
        <div class="flex items-start justify-between gap-3 mb-3">
            <div>
                <p class="text-xs uppercase tracking-[0.2em] text-sky-300/80 mb-1">
                    Centro de ayuda
                </p>
                <h3 class="lp-modal-title titulo">
                    Envíanos tu solicitud de soporte
                </h3>
                <p class="text-[11px] sm:text-xs text-slate-400 mt-1">
                    PQRS: Peticiones, Quejas, Reclamos o Sugerencias sobre tus eventos o tickets.
                </p>
            </div>
            <button type="button"
                    id="btnCerrarSoporte"
                    class="w-8 h-8 flex items-center justify-center rounded-full border border-slate-600/60 text-slate-300/80 hover:bg-slate-800/80 hover:text-white transition">
                <span class="material-icons text-sm">close</span>
            </button>
        </div>

        <!-- Mensaje de estado -->
        <div id="soporteStatus"
             class="hidden mb-3 px-3 py-2 rounded-lg text-xs"></div>

        <!-- FORM -->
        <form id="formSoporte" class="space-y-3">
            <!-- Nombre -->
            <div>
                <label class="block text-xs text-slate-200/90 mb-1">
                    Nombre completo
                </label>
                <input id="sptNombre"
                       name="nombre"
                       type="text"
                       required
                       class="lp-modal-input w-full px-3.5 py-2.5"
                       placeholder="Ej: Daniela Gómez"
                       value="<%= (userName != null ? userName : "") %>">
            </div>

            <!-- Email -->
            <div>
                <label class="block text-xs text-slate-200/90 mb-1">
                    Correo electrónico
                </label>
                <input id="sptEmail"
                       name="email"
                       type="email"
                       required
                       class="lp-modal-input w-full px-3.5 py-2.5"
                       placeholder="tucorreo@ejemplo.com"
                       value="<%= (session.getAttribute("email") != null ? (String)session.getAttribute("email") : "") %>">
            </div>

            <!-- Mensaje -->
            <div>
                <label class="block text-xs text-slate-200/90 mb-1">
                    Describe tu solicitud (PQRS)
                </label>
                <textarea id="sptMensaje"
                          name="mensaje"
                          rows="4"
                          required
                          class="lp-modal-textarea w-full px-3.5 py-2.5 resize-none"
                          placeholder="Cuéntanos qué necesitas: petición, queja, reclamo o sugerencia."></textarea>
            </div>

            <!-- CTA -->
            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mt-2">
                <p class="text-[10px] text-slate-500 max-w-xs">
                    Nuestro equipo de soporte revisará tu solicitud y te responderá al correo registrado.
                </p>
                <button type="submit"
                        id="btnEnviarSoporte"
                        class="btn-solid px-5 py-2 rounded-xl text-xs sm:text-sm flex items-center justify-center gap-1.5">
                    <span class="material-icons text-sm">send</span>
                    <span>Enviar solicitud</span>
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ===========================
     JS CARRUSEL + MENÚ + SOPORTE
=========================== -->
<script>
  // Carrusel
  (function(){
      const track   = document.getElementById('carouselCards');
      if (!track) return;

      const prev    = document.getElementById('arrowPrev');
      const next    = document.getElementById('arrowNext');
      const prevM   = document.getElementById('arrowPrevMobile');
      const nextM   = document.getElementById('arrowNextMobile');

      function scrollByCards(direction){
          const card = track.querySelector('.relative.min-w-[240px]');
          if (!card) return;
          const cardWidth = card.getBoundingClientRect().width + 16; // ancho + gap aprox
          track.scrollBy({
              left: direction * cardWidth * 1.2,
              behavior: 'smooth'
          });
      }

      [prev, prevM].forEach(btn => {
          if (btn) btn.addEventListener('click', () => scrollByCards(-1));
      });
      [next, nextM].forEach(btn => {
          if (btn) btn.addEventListener('click', () => scrollByCards(1));
      });
  })();

  // Menú hamburguesa
  (function(){
      const btn  = document.getElementById('btnMenu');
      const menu = document.getElementById('mobileMenu');
      if (!btn || !menu) return;

      btn.addEventListener('click', function(){
          menu.classList.toggle('hidden');
          btn.classList.toggle('open');
      });
  })();

  // SOPORTE: BOTÓN FLOTANTE + MODAL + AJAX
  (function(){
      const btnSoporte   = document.getElementById('btnSoporte');
      const modal        = document.getElementById('modalSoporte');
      const backdrop     = document.getElementById('modalSoporteBackdrop');
      const btnCerrar    = document.getElementById('btnCerrarSoporte');
      const form         = document.getElementById('formSoporte');
      const statusBox    = document.getElementById('soporteStatus');
      const btnEnviar    = document.getElementById('btnEnviarSoporte');

      if (!btnSoporte || !modal || !form) return;

      const soporteUrl = '<%= request.getContextPath() %>/Soporte';

      function abrirModal(){
          modal.classList.remove('hidden');
          modal.classList.add('flex');
          statusBox.classList.add('hidden');
          statusBox.textContent = '';
          document.body.classList.add('overflow-hidden');
      }

      function cerrarModal(){
          modal.classList.add('hidden');
          modal.classList.remove('flex');
          document.body.classList.remove('overflow-hidden');
          form.reset();
          statusBox.classList.add('hidden');
          statusBox.textContent = '';
      }

      btnSoporte.addEventListener('click', abrirModal);
      if (btnCerrar)   btnCerrar.addEventListener('click', cerrarModal);
      if (backdrop)    backdrop.addEventListener('click', cerrarModal);

      // Enviar formulario por AJAX
      form.addEventListener('submit', function(e){
          e.preventDefault();

          const nombre  = document.getElementById('sptNombre').value.trim();
          const email   = document.getElementById('sptEmail').value.trim();
          const mensaje = document.getElementById('sptMensaje').value.trim();

          if (!nombre || !email || !mensaje) {
              mostrarStatus('Todos los campos son obligatorios.', 'error');
              return;
          }

          btnEnviar.disabled = true;
          btnEnviar.classList.add('opacity-70','cursor-wait');

          const body = new URLSearchParams();
          body.append('nombre', nombre);
          body.append('email', email);
          body.append('mensaje', mensaje);

          fetch(soporteUrl, {
              method: 'POST',
              headers: {
                  'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
              },
              body
          })
          .then(r => r.json())
          .then(data => {
              if (data.status === 'ok') {
                  mostrarStatus('Tu mensaje fue enviado correctamente. Te responderemos a tu correo. ✅', 'ok');
                  setTimeout(() => {
                      cerrarModal();
                  }, 1500);
              } else {
                  mostrarStatus(data.msg || 'No se pudo enviar el mensaje.', 'error');
              }
          })
          .catch(() => {
              mostrarStatus('Error de conexión. Intenta nuevamente en unos minutos.', 'error');
          })
          .finally(() => {
              btnEnviar.disabled = false;
              btnEnviar.classList.remove('opacity-70','cursor-wait');
          });
      });

      function mostrarStatus(msg, tipo){
          statusBox.textContent = msg;
          statusBox.classList.remove('hidden');

          statusBox.classList.remove('bg-emerald-600/20','border-emerald-400/50','text-emerald-200');
          statusBox.classList.remove('bg-pink-700/25','border-pink-500/60','text-pink-100');

          if (tipo === 'ok') {
              statusBox.classList.add('bg-emerald-600/20','border-emerald-400/50','text-emerald-200');
          } else {
              statusBox.classList.add('bg-pink-700/25','border-pink-500/60','text-pink-100');
          }
      }
  })();
</script>

</body>
</html>
