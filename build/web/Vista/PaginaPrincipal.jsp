<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dao.EventDAO" %>
<%@ page import="utils.Event" %>
<%@ page import="java.util.List" %>

<%
    // ==========================
    // CARGAR EVENTOS CARRUSEL DESDE BD
    // ==========================
    List<Event> featured = null;
    try {
        EventDAO dao = new EventDAO();
        featured = dao.listFeatured(10); // hasta 10 eventos en el slider
    } catch (Exception ex) {
        ex.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <title>LivePassBuga - Página Principal</title>

    <!-- TAILWIND -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- Archivos CSS generales -->
    <link rel="stylesheet" href="../Styles/estilos.css">

    <!-- Iconos Material -->
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

    <style>
        /* NAV más pro */
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

        .brand-wrapper{
            display:flex;
            align-items:center;
            gap:.6rem;
        }
        .brand-logo{
            width:110px;
            height:auto;
            filter:drop-shadow(0 10px 25px rgba(0,0,0,.65));
            transition:transform .18s ease, filter .18s ease;
        }
        .brand-wrapper:hover .brand-logo{
            transform:translateY(-1px) scale(1.02);
            filter:drop-shadow(0 18px 40px rgba(0,0,0,.9));
        }
        .brand-sub{
            font-size:.68rem;
            letter-spacing:.24em;
            text-transform:uppercase;
            color:rgba(148,163,184,.85);
        }

        /* Botones header */
        .btn-outline{
            border-radius:.75rem;
            padding:.45rem 1.3rem;
            border:1px solid rgba(0,224,198,.8);
            color:#00E0C6;
            font-weight:600;
            font-size:.85rem;
            transition:all .18s ease;
        }
        .btn-outline:hover{
            background:#00E0C6;
            color:#020617;
            box-shadow:0 12px 30px rgba(0,224,198,.35);
            transform:translateY(-1px);
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
            box-shadow:0 12px 30px rgba(84,105,213,.4);
            transform:translateY(-1px);
        }

        /* Scrollbar oculto */
        .no-scrollbar::-webkit-scrollbar{
            display:none;
        }
        .no-scrollbar{
            -ms-overflow-style:none;
            scrollbar-width:none;
        }

        /* FONDO CAMUFLADO: sin panel, sin borde, mismo bg que la página */
        .card-carousel{
            background:transparent;
            border-radius:0;
            border:none;
            box-shadow:none;
            padding:0;
        }

        /* ====== CARD COMERCIAL ====== */
        .card-event{
            position:relative;
            min-width:260px;
            max-width:260px;
            border-radius:1.4rem;
            overflow:hidden;
            background:#0B0F1A;
            padding:0;
            cursor:pointer;
            transition:transform .35s ease, box-shadow .35s ease, z-index .15s ease;
            box-shadow:0 10px 25px rgba(0,0,0,.45);
            z-index:1; /* base */
        }
        .card-event:hover{
            transform:translateY(-8px) scale(1.06);
            box-shadow:0 25px 60px rgba(0,0,0,.8);
            z-index:50; /* por encima de todo lo demás */
        }

        .img-wrap{
            position:relative;
            height:180px;
            overflow:hidden;
        }
        .img-wrap img{
            width:100%;
            height:100%;
            object-fit:cover;
            transition:transform .45s ease;
        }
        .card-event:hover .img-wrap img{
            transform:scale(1.12);
        }

        .badge-top{
            position:absolute;
            top:10px;
            left:12px;
            background:rgba(0,224,198,.20);
            backdrop-filter:blur(6px);
            padding:.25rem .65rem;
            font-size:.65rem;
            border-radius:.5rem;
            letter-spacing:.15em;
            text-transform:uppercase;
            color:#00E0C6;
            font-weight:600;
        }

        .card-gradient{
            position:absolute;
            bottom:0;
            left:0;
            width:100%;
            height:50%;
            background:linear-gradient(to top,rgba(0,0,0,.8),transparent);
        }

        .card-content{
            padding:1rem 1rem 1.3rem 1rem;
        }
        .card-location{
            font-size:.75rem;
            color:#9ca3af;
            text-transform:uppercase;
            letter-spacing:.15em;
            margin-bottom:.4rem;
        }
        .card-title{
            font-size:1rem;
            font-weight:700;
            margin-bottom:.2rem;
        }
        .card-date{
            font-size:.8rem;
            color:#cbd5e1;
        }
        .card-price{
            font-size:.85rem;
            font-weight:600;
            margin-top:.6rem;
            color:#5469D5;
        }

        .buy-btn{
            position:absolute;
            bottom:16px;
            right:16px;
            padding:.45rem .9rem;
            border-radius:999px;
            font-size:.75rem;
            font-weight:600;
            background:linear-gradient(135deg,#5469D5,#00E0C6);
            color:white;
            opacity:0;
            pointer-events:none;
            transform:translateY(10px);
            transition:all .35s ease;
            text-decoration:none;
        }
        .card-event:hover .buy-btn{
            opacity:1;
            pointer-events:auto;
            transform:translateY(0);
        }

        /* Botones flecha carrusel */
        .arrow-btn{
            width:34px;
            height:34px;
            border-radius:999px;
            border:1px solid rgba(148,163,184,.45);
            display:flex;
            align-items:center;
            justify-content:center;
            font-size:18px;
            background:radial-gradient(circle at top,rgba(15,23,42,1),rgba(15,23,42,.9));
            cursor:pointer;
            transition:background .18s ease, transform .18s ease, box-shadow .18s ease;
        }
        .arrow-btn:hover{
            background:linear-gradient(135deg,#5469D5,#00E0C6);
            box-shadow:0 16px 35px rgba(15,23,42,.9);
            transform:translateY(-1px);
        }

        /* CLAVE: permitir que las cards salgan hacia arriba */
        #carouselCards{
            overflow-y:visible;
        }

        /* Secciones inferiores (info de interés) */
        .section-title{
            font-size:1.5rem;
            font-weight:700;
        }
        .pill{
            border-radius:999px;
            padding:.3rem .9rem;
            font-size:.7rem;
            letter-spacing:.15em;
            text-transform:uppercase;
        }
    </style>
</head>

<body class="bg-[#0A0C14] text-white">

<!-- ===========================
     NAVBAR
=========================== -->
<header id="lp-nav" class="sticky top-0 z-30">
    <div class="w-full border-b border-white/10 bg-[#050812]/95 backdrop-blur">
        <div class="max-w-6xl mx-auto px-6 py-3 flex items-center justify-between gap-4">

            <!-- LOGO + subtítulo -->
           <a href="PaginaPrincipal.jsp" class="brand-wrapper select-none">
    <img src="../Imagenes/Livepass Buga Logo.png"
         alt="LivePassBuga"
         class="brand-logo"
         draggable="false">
    <span class="hidden sm:block brand-sub">Tickets &amp; eventos</span>
</a>


            <!-- MENÚ -->
            <ul class="hidden md:flex gap-8 items-center text-sm font-medium">
                <li><a href="#" class="nav-link">Inicio</a></li>
                <li><a href="#" class="nav-link">Eventos</a></li>
                <li><a href="#" class="nav-link">Categorías</a></li>
                <li><a href="../Vista/Soporte.jsp" class="nav-link">Soporte</a></li>
            </ul>

           
            <!-- BOTONES -->
                <div class="hidden md:flex gap-3">
                    <!-- Ingresar -->
                    <a href="<%= request.getContextPath() %>/Vista/Login.jsp"
                       class="btn-outline inline-flex items-center justify-center">
                        Ingresar
                    </a>

                    <!-- Registrarse -->
                    <a href="<%= request.getContextPath() %>/Vista/Registro.jsp"
                       class="btn-solid inline-flex items-center justify-center">
                        Registrarse
                    </a>
                </div> 

        </div>
    </div>
</header>


<!-- ===========================
     HERO SECTION
=========================== -->
<section class="relative w-full h-[450px] mt-2">
    <!-- fondo principal -->
    <img src="https://images.pexels.com/photos/1190297/pexels-photo-1190297.jpeg?auto=compress&cs=tinysrgb&w=1600"
         class="w-full h-full object-cover opacity-60">
  
    <div class="absolute top-20 left-10 max-w-xl">
        <p class="text-sm" style="color:#00E0C6;">Plataforma moderna</p>

        <h1 class="text-4xl font-bold leading-tight titulo">
            Compra, gestiona y valida <span style="color:#5469D5">tickets con QR</span>
        </h1>

        <p class="mt-2 text-sm md:text-base">
            Experiencia sin filas, validación instantánea y seguridad total para eventos.
        </p>

        <!-- BARRA DE BÚSQUEDA -->
        <div class="mt-6">
            <div class="flex items-center bg-white rounded-md shadow-md px-3 py-2 w-[320px] md:w-[420px]">
                <span class="material-icons text-gray-500 mr-2">search</span>
                <input
                    type="text"
                    placeholder="Buscar eventos"
                    class="w-full outline-none text-sm"
                    style="color:#6D6E6E;">
            </div>
        </div>
    </div>

    <!-- PANEL LATERAL -->
    <div class="absolute right-4 md:right-10 top-8 w-[280px] md:w-[300px] p-4 rounded-xl shadow-xl card bg-[#050816]/90 backdrop-blur">
        <img src="https://images.pexels.com/photos/167636/pexels-photo-167636.jpeg?auto=compress&cs=tinysrgb&w=800"
             class="rounded-lg w-full h-[180px] object-cover">
        <h2 class="mt-3 text-lg font-bold titulo">Próximo evento</h2>
        <p class="text-sm">Line up sorpresa • Lago Calima</p>
        <p class="mt-1 font-semibold" style="color:#5469D5">$80.000 - $350.000</p>

        <button class="btn-primary w-full mt-3 py-2 rounded-lg bg-[#5469D5]">Reservar</button>
        <button class="btn-secondary w-full mt-2 text-sm py-2 rounded-lg border border-white/20">
            Ver Detalles
        </button>
    </div>
</section>


<!-- ===========================
     CARRUSEL DE EVENTOS (SLIDER)
=========================== -->
<section class="mt-12 px-6 md:px-10 max-w-6xl mx-auto overflow-visible">
    <div class="flex items-center justify-between mb-4 gap-4">
        <div>
            <h2 class="text-2xl font-bold titulo">Popular esta semana</h2>
            <p class="text-sm text-slate-300/80">Explora lo que más están comprando ahora</p>
        </div>

        <div class="hidden md:flex items-center gap-2">
            <button id="arrowPrev" class="arrow-btn">
                <span class="material-icons text-sm">chevron_left</span>
            </button>
            <button id="arrowNext" class="arrow-btn">
                <span class="material-icons text-sm">chevron_right</span>
            </button>
        </div>
    </div>

    <div class="card-carousel">
        <div id="carouselCards"
             class="flex gap-4 md:gap-5 overflow-x-auto overflow-y-visible scroll-smooth no-scrollbar relative z-0">

            <%
                if (featured != null && !featured.isEmpty()) {
                    java.time.format.DateTimeFormatter DT_FMT =
                            java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
                    java.text.NumberFormat NF_CO =
                            java.text.NumberFormat.getCurrencyInstance(new java.util.Locale("es","CO"));

                    for (Event ev : featured) {

                        String image = (ev.getImage() != null && !ev.getImage().isEmpty())
                                ? ev.getImage()
                                // imagen por defecto desde internet
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

            <article class="card-event">

                <div class="img-wrap">
                    <img src="<%= image %>"
                         alt="<%= ev.getImageAlt() != null ? ev.getImageAlt() : titulo %>">
                    <div class="badge-top"><%= categoria %></div>
                    <div class="card-gradient"></div>
                </div>

                <div class="card-content">
                    <p class="card-location">
                        <%= ciudad %><% if (!ciudad.isEmpty() && !venue.isEmpty()) { %> • <% } %><%= venue %>
                    </p>
                    <h3 class="card-title"><%= titulo %></h3>
                    <p class="card-date"><%= fecha %></p>

                    <% if (!precio.isEmpty()) { %>
                    <p class="card-price">Desde <%= precio %></p>
                    <% } %>
                </div>

                <a href="EventoDetalle.jsp?id=<%= ev.getId() %>" class="buy-btn">
                    Comprar
                </a>

            </article>

            <%
                    }
                } else {
            %>
            <!-- Fallback si no hay eventos -->
            <article class="card-event">
                <div class="img-wrap">
                    <img src="https://images.pexels.com/photos/1190297/pexels-photo-1190297.jpeg?auto=compress&cs=tinysrgb&w=800"
                         alt="Sin eventos">
                    <div class="card-gradient"></div>
                </div>
                <div class="card-content">
                    <p class="card-location">Sin eventos</p>
                    <h3 class="card-title">Aún no hay eventos publicados</h3>
                    <p class="card-date">
                        Cuando publiques tus eventos, aparecerán aquí automáticamente.
                    </p>
                </div>
            </article>
            <%
                }
            %>

        </div>
    </div>

    <!-- Flechas móviles debajo -->
    <div class="flex md:hidden justify-end gap-2 mt-3">
        <button id="arrowPrevMobile" class="arrow-btn">
            <span class="material-icons text-sm">chevron_left</span>
        </button>
        <button id="arrowNextMobile" class="arrow-btn">
            <span class="material-icons text-sm">chevron_right</span>
        </button>
    </div>
</section>


<!-- ===========================
     PRÓXIMOS LANZAMIENTOS
=========================== -->
<section class="mt-16 px-6 md:px-10 max-w-6xl mx-auto">
    <div class="flex items-center justify-between mb-4">
        <div>
            <p class="pill bg-[#111827] text-[#9ca3af] mb-2">Nuevos en LivePassBuga</p>
            <h2 class="section-title titulo">Próximos lanzamientos</h2>
            <p class="text-sm text-slate-300/80">
                Asegura tu lugar antes de que se agoten los cupos.
            </p>
        </div>
        <button class="hidden md:inline-flex items-center gap-2 px-4 py-2 rounded-full text-xs font-semibold
                       bg-gradient-to-r from-[#5469D5] to-[#00E0C6]">
            Ver todos los eventos
            <span class="material-icons text-xs">arrow_forward</span>
        </button>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        <!-- Card estática 1 -->
        <div class="rounded-2xl overflow-hidden bg-[#050816] border border-white/5 shadow-xl">
            <img src="https://images.pexels.com/photos/167636/pexels-photo-167636.jpeg?auto=compress&cs=tinysrgb&w=1200"
                 class="w-full h-44 object-cover" alt="Concierto urbano">
            <div class="p-4">
                <p class="text-xs tracking-[0.2em] uppercase text-[#00E0C6] mb-1">
                    Buga · Coliseo
                </p>
                <h3 class="font-semibold titulo mb-1">Urbano Night Fest</h3>
                <p class="text-xs text-slate-300 mb-2">
                    Line up con artistas urbanos invitados, visuales y show de luces.
                </p>
                <div class="flex items-center justify-between text-xs mt-2">
                    <span class="font-semibold text-[#5469D5]">Desde $ 80.000</span>
                    <button class="px-3 py-1 rounded-full bg-white text-black text-[11px] font-semibold">
                        Comprar ahora
                    </button>
                </div>
            </div>
        </div>

        <!-- Card estática 2 -->
        <div class="rounded-2xl overflow-hidden bg-[#050816] border border-white/5 shadow-xl">
            <img src="https://images.pexels.com/photos/1105666/pexels-photo-1105666.jpeg?auto=compress&cs=tinysrgb&w=1200"
                 class="w-full h-44 object-cover" alt="Festival al aire libre">
            <div class="p-4">
                <p class="text-xs tracking-[0.2em] uppercase text-[#00E0C6] mb-1">
                    Lago Calima · Sunset
                </p>
                <h3 class="font-semibold titulo mb-1">Sunset Lake Festival</h3>
                <p class="text-xs text-slate-300 mb-2">
                    DJs, food trucks y cocteles frente al atardecer del lago.
                </p>
                <div class="flex items-center justify-between text-xs mt-2">
                    <span class="font-semibold text-[#5469D5]">Desde $ 120.000</span>
                    <button class="px-3 py-1 rounded-full bg-white text-black text-[11px] font-semibold">
                        Comprar ahora
                    </button>
                </div>
            </div>
        </div>

        <!-- Card estática 3 -->
        <div class="rounded-2xl overflow-hidden bg-[#050816] border border-white/5 shadow-xl">
            <img src="https://images.pexels.com/photos/7131497/pexels-photo-7131497.jpeg?auto=compress&cs=tinysrgb&w=1200"
                 class="w-full h-44 object-cover" alt="Obra de teatro">
            <div class="p-4">
                <p class="text-xs tracking-[0.2em] uppercase text-[#00E0C6] mb-1">
                    Teatro Municipal
                </p>
                <h3 class="font-semibold titulo mb-1">Noche de Stand-Up & Teatro</h3>
                <p class="text-xs text-slate-300 mb-2">
                    Comedia, storytelling y una puesta en escena íntima.
                </p>
                <div class="flex items-center justify-between text-xs mt-2">
                    <span class="font-semibold text-[#5469D5]">Desde $ 60.000</span>
                    <button class="px-3 py-1 rounded-full bg-white text-black text-[11px] font-semibold">
                        Comprar ahora
                    </button>
                </div>
            </div>
        </div>
    </div>
</section>


<!-- ===========================
     BENEFICIOS / POR QUÉ COMPRAR AQUÍ
=========================== -->
<section class="mt-16 px-6 md:px-10 max-w-6xl mx-auto">
    <div class="grid md:grid-cols-2 gap-10 items-center">
        <div>
            <p class="pill bg-[#111827] text-[#9ca3af] mb-3">Confianza para tus eventos</p>
            <h2 class="section-title titulo mb-3">
                Una plataforma pensada para organizadores y asistentes exigentes.
            </h2>
            <p class="text-sm text-slate-300 mb-4">
                LivePassBuga centraliza la venta de tickets, el control de acceso y la
                información de tus asistentes en una sola plataforma, segura y fácil de usar.
            </p>

            <ul class="space-y-3 text-sm text-slate-200">
                <li class="flex gap-3">
                    <span class="material-icons text-[#00E0C6] text-base mt-[2px]">verified</span>
                    <div>
                        <p class="font-semibold">Pagos verificados y seguros</p>
                        <p class="text-xs text-slate-400">
                            Integración con pasarelas de pago, validación QR y reportes en tiempo real.
                        </p>
                    </div>
                </li>
                <li class="flex gap-3">
                    <span class="material-icons text-[#00E0C6] text-base mt-[2px]">qr_code_scanner</span>
                    <div>
                        <p class="font-semibold">Check-in ultra rápido</p>
                        <p class="text-xs text-slate-400">
                            Escanea tickets desde cualquier dispositivo y controla el aforo de manera profesional.
                        </p>
                    </div>
                </li>
                <li class="flex gap-3">
                    <span class="material-icons text-[#00E0C6] text-base mt-[2px]">insights</span>
                    <div>
                        <p class="font-semibold">Datos que se convierten en ventas</p>
                        <p class="text-xs text-slate-400">
                            Estadísticas por tipo de entrada, ciudad, canal de venta y comportamiento de compra.
                        </p>
                    </div>
                </li>
            </ul>
        </div>

        <div class="grid grid-cols-2 gap-4">
            <div class="row-span-2 rounded-2xl overflow-hidden bg-[#050816] border border-white/5">
                <img src="https://images.pexels.com/photos/1190297/pexels-photo-1190297.jpeg?auto=compress&cs=tinysrgb&w=1200"
                     class="w-full h-full object-cover"
                     alt="Público disfrutando concierto">
            </div>
            <div class="rounded-2xl overflow-hidden bg-[#050816] border border-white/5">
                <img src="https://images.pexels.com/photos/6898859/pexels-photo-6898859.jpeg?auto=compress&cs=tinysrgb&w=800"
                     class="w-full h-32 object-cover"
                     alt="Backstage producción">
            </div>
            <div class="rounded-2xl overflow-hidden bg-gradient-to-br from-[#111827] to-[#020617] border border-white/10 p-4 flex flex-col justify-between">
                <div>
                    <p class="text-xs text-[#9ca3af] mb-1">Organizadores</p>
                    <p class="font-semibold titulo text-sm mb-2">Dashboard de ventas en vivo</p>
                    <p class="text-xs text-slate-400">
                        Ve cuántas entradas se han vendido por zona, canal y horario.
                    </p>
                </div>
                <button class="mt-4 px-3 py-2 text-[11px] rounded-full border border-[#00E0C6] text-[#00E0C6]">
                    Solicitar demo para organizadores
                </button>
            </div>
        </div>
    </div>
</section>


<!-- ===========================
     CATEGORÍAS DESTACADAS
=========================== -->
<section class="mt-16 px-6 md:px-10 max-w-6xl mx-auto">
    <div class="flex items-center justify-between mb-6">
        <div>
            <p class="pill bg-[#111827] text-[#9ca3af] mb-2">Encuentra tu plan</p>
            <h2 class="section-title titulo">Explora por categoría</h2>
        </div>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <!-- Conciertos -->
        <div class="relative overflow-hidden rounded-2xl bg-[#050816] border border-white/5 group">
            <img src="https://images.pexels.com/photos/3374222/pexels-photo-3374222.jpeg?auto=compress&cs=tinysrgb&w=1200"
                 class="w-full h-40 object-cover opacity-80 group-hover:scale-105 transition-transform"
                 alt="Conciertos">
            <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent"></div>
            <div class="absolute bottom-3 left-3 right-3">
                <p class="text-xs text-[#9ca3af] uppercase tracking-[0.2em]">Vive la música</p>
                <p class="font-semibold titulo text-sm">Conciertos & Festivales</p>
            </div>
        </div>

        <!-- Electrónica -->
        <div class="relative overflow-hidden rounded-2xl bg-[#050816] border border-white/5 group">
            <img src="https://images.pexels.com/photos/1047440/pexels-photo-1047440.jpeg?auto=compress&cs=tinysrgb&w=1200"
                 class="w-full h-40 object-cover opacity-80 group-hover:scale-105 transition-transform"
                 alt="Electrónica">
            <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent"></div>
            <div class="absolute bottom-3 left-3 right-3">
                <p class="text-xs text-[#9ca3af] uppercase tracking-[0.2em]">Atardeceres & clubs</p>
                <p class="font-semibold titulo text-sm">Electrónica & Sunsets</p>
            </div>
        </div>

        <!-- Familiar -->
        <div class="relative overflow-hidden rounded-2xl bg-[#050816] border border-white/5 group">
            <img src="https://images.pexels.com/photos/2253879/pexels-photo-2253879.jpeg?auto=compress&cs=tinysrgb&w=1200"
                 class="w-full h-40 object-cover opacity-80 group-hover:scale-105 transition-transform"
                 alt="Eventos familiares">
            <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent"></div>
            <div class="absolute bottom-3 left-3 right-3">
                <p class="text-xs text-[#9ca3af] uppercase tracking-[0.2em]">Niños & familias</p>
                <p class="font-semibold titulo text-sm">Eventos familiares</p>
            </div>
        </div>

        <!-- Corporativos -->
        <div class="relative overflow-hidden rounded-2xl bg-[#050816] border border-white/5 group">
            <img src="https://images.pexels.com/photos/1181395/pexels-photo-1181395.jpeg?auto=compress&cs=tinysrgb&w=1200"
                 class="w-full h-40 object-cover opacity-80 group-hover:scale-105 transition-transform"
                 alt="Eventos corporativos">
            <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent"></div>
            <div class="absolute bottom-3 left-3 right-3">
                <p class="text-xs text-[#9ca3af] uppercase tracking-[0.2em]">Empresas & marcas</p>
                <p class="font-semibold titulo text-sm">Corporativos & conferencias</p>
            </div>
        </div>
    </div>
</section>


<!-- ===========================
     CÓMO FUNCIONA + VIDEO
=========================== -->
<section class="mt-16 px-6 md:px-10 max-w-6xl mx-auto">
    <div class="rounded-3xl border border-white/5 bg-gradient-to-r from-[#020617] via-[#020617] to-[#020617] p-6 md:p-8 flex flex-col md:flex-row gap-8 items-center">
        <div class="flex-1">
            <p class="pill bg-[#111827] text-[#9ca3af] mb-3">Compra en 3 pasos</p>
            <h2 class="section-title titulo mb-3">Así de fácil es asegurar tu entrada</h2>
            <ol class="space-y-3 text-sm text-slate-200 list-decimal list-inside">
                <li>
                    <span class="font-semibold">Elige tu evento favorito.</span>
                    <span class="text-slate-400 text-xs ml-1">
                        Filtra por ciudad, fecha o categoría.
                    </span>
                </li>
                <li>
                    <span class="font-semibold">Selecciona la zona y cantidad de tickets.</span>
                    <span class="text-slate-400 text-xs ml-1">
                        VIP, general, boxes o mesas, todo en una misma interfaz.
                    </span>
                </li>
                <li>
                    <span class="font-semibold">Paga y recibe tu QR al instante.</span>
                    <span class="text-slate-400 text-xs ml-1">
                        Recíbelo en tu correo y preséntalo desde tu celular.
                    </span>
                </li>
            </ol>
        </div>

        <div class="flex-1 w-full">
            <!-- Video demo: cambia el link por tu video oficial -->
            <div class="relative w-full aspect-video rounded-2xl overflow-hidden border border-white/10 shadow-2xl">
                <iframe
                    class="w-full h-full"
                    src="https://www.youtube.com/embed/ScMzIvxBSi4"
                    title="Video promocional LivePassBuga"
                    frameborder="0"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                    allowfullscreen>
                </iframe>
            </div>
            <p class="mt-3 text-[11px] text-slate-400">
                Reemplaza este video por el oficial de tu marca cuando lo tengas listo.
            </p>
        </div>
    </div>
</section>


<!-- ===========================
     CTA FINAL
=========================== -->
<section class="mt-16 mb-12 px-6 md:px-10 max-w-6xl mx-auto">
    <div class="rounded-3xl bg-gradient-to-r from-[#5469D5] via-[#4f46e5] to-[#00E0C6] p-[1px]">
        <div class="rounded-3xl bg-[#020617] px-6 py-6 md:px-10 md:py-8 flex flex-col md:flex-row items-center justify-between gap-6">
            <div>
                <p class="text-xs uppercase tracking-[0.2em] text-[#a5b4fc] mb-1">
                    Para organizadores y productores
                </p>
                <h2 class="section-title titulo mb-2">
                    ¿Quieres vender tus próximos eventos con LivePassBuga?
                </h2>
                <p class="text-sm text-slate-200 max-w-xl">
                    Centraliza tu boletería, controla el acceso con QR y ofrece una experiencia
                    profesional a tu público desde el primer clic.
                </p>
            </div>
            <div class="flex flex-col sm:flex-row gap-3">
                <button class="px-5 py-2 rounded-full bg-white text-black text-sm font-semibold">
                    Agendar una demo
                </button>
                <button class="px-5 py-2 rounded-full border border-white/40 text-sm font-semibold">
                    Ver planes para organizadores
                </button>
            </div>
        </div>
    </div>
</section>


<!-- ===========================
     JS CARRUSEL
=========================== -->
<script>
  (function(){
      const track   = document.getElementById('carouselCards');
      if (!track) return;

      const prev    = document.getElementById('arrowPrev');
      const next    = document.getElementById('arrowNext');
      const prevM   = document.getElementById('arrowPrevMobile');
      const nextM   = document.getElementById('arrowNextMobile');

      function scrollByCards(direction){
          const card = track.querySelector('.card-event');
          if (!card) return;
          const cardWidth = card.getBoundingClientRect().width + 16; // ancho + gap
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
</script>

</body>
</html>
