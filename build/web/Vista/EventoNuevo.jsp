<%@ page contentType="text/html; charset=UTF-8" %>
<%
  Integer uid  = (Integer) session.getAttribute("userId");
  String  role = (String)  session.getAttribute("role");

  if (uid == null) {
    response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp");
    return;
  }
  if (role == null || !"ORGANIZADOR".equalsIgnoreCase(role)) {
    response.sendRedirect(request.getContextPath()+"/Vista/HomeCliente.jsp");
    return;
  }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Nuevo evento</title>

  <style>
    :root{
      --hero-img: url("https://images.pexels.com/photos/1190297/pexels-photo-1190297.jpeg?auto=compress&cs=tinysrgb&w=1600");
      --accent:#22e3c4;
      --accent2:#6c5ce7;
    }

    body{
      min-height:100vh;
      background:#020617;
      color:#e5e7eb;
      font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      -webkit-font-smoothing:antialiased;
    }

    .lp-hero{
      position:relative;
      min-height:calc(100vh - 64px);
      display:flex;
      align-items:flex-start;
      justify-content:center;
      padding:3.5rem 1.25rem 3rem;
    }
    .lp-hero::before{
      content:"";
      position:absolute;
      inset:0;
      background-image:var(--hero-img);
      background-size:cover;
      background-position:center;
      filter:brightness(0.55);
    }
    .lp-hero::after{
      content:"";
      position:absolute;
      inset:0;
      background:radial-gradient(circle at top,rgba(56,189,248,.55),transparent 55%),
                 linear-gradient(to bottom,rgba(15,23,42,.85),rgba(15,23,42,.96));
      mix-blend-mode:screen;
      opacity:.85;
    }

    .lp-hero-inner{
      position:relative;
      z-index:1;
      width:100%;
      max-width:64rem;
    }

    /* NAV DE PASOS */
    .lp-steps{
      display:flex;
      justify-content:space-between;
      align-items:center;
      gap:1.5rem;
      margin-bottom:2.75rem;
      padding:0 0.5rem;
      color:#e5e7eb;
      font-size:.75rem;
    }
    .lp-step{
      flex:1;
      text-align:center;
      position:relative;
      opacity:.6;
    }
    .lp-step:not(:last-child)::after{
      content:"";
      position:absolute;
      top:16px;
      right:-50%;
      width:100%;
      height:3px;
      background:linear-gradient(90deg,rgba(148,163,184,.45),rgba(148,163,184,.1));
    }
    .lp-step-pill{
      display:inline-flex;
      align-items:center;
      justify-content:center;
      width:32px;
      height:32px;
      border-radius:999px;
      background:rgba(15,23,42,.9);
      border:1px solid rgba(148,163,184,.55);
      box-shadow:0 0 0 1px rgba(15,23,42,1),
                 0 0 18px rgba(15,23,42,1);
      margin-bottom:.3rem;
      font-size:.8rem;
    }
    .lp-step-label{
      display:block;
      font-weight:600;
    }
    .lp-step-sub{
      display:block;
      font-size:.68rem;
      opacity:.7;
      margin-top:2px;
    }
    .lp-step--active{
      opacity:1;
    }
    .lp-step--active .lp-step-pill{
      border-color:var(--accent);
      background:radial-gradient(circle at top,var(--accent),rgba(15,23,42,1));
      box-shadow:0 0 22px rgba(34,227,196,.8);
      color:#0b1120;
      font-weight:700;
    }
    .lp-step--done .lp-step-pill{
      border-color:var(--accent2);
      background:radial-gradient(circle at top,var(--accent2),rgba(15,23,42,1));
      color:#e5e7eb;
    }

    /* CARD */
    .lp-card{
      background:rgba(15,23,42,.96);
      border-radius:22px;
      border:1px solid rgba(148,163,184,.55);
      box-shadow:0 22px 60px rgba(0,0,0,.9);
      backdrop-filter:blur(18px);
      padding:2.1rem 2.4rem 2.4rem;
    }
    @media (max-width:767px){
      .lp-steps{display:none;}
      .lp-card{padding:1.7rem 1.4rem 1.9rem;border-radius:18px;}
    }

    .lp-chip{
      display:inline-flex;
      align-items:center;
      gap:.45rem;
      padding:.28rem .7rem;
      border-radius:999px;
      border:1px solid rgba(148,163,184,.65);
      background:rgba(15,23,42,.9);
      font-size:.7rem;
      text-transform:uppercase;
      letter-spacing:.08em;
      color:#cbd5f5;
    }
    .lp-chip-dot{
      width:7px; height:7px;
      border-radius:999px;
      background:var(--accent);
      box-shadow:0 0 12px rgba(34,227,196,.9);
    }

    .field-label{
      font-size:.8rem;
      font-weight:600;
      color:#e5e7eb;
      margin-bottom:.3rem;
      display:flex;
      align-items:center;
      gap:.4rem;
    }
    .field-label span.helper{
      font-size:.7rem;
      font-weight:400;
      color:#9ca3af;
    }

    .field-input, .field-textarea, .ui-select{
      width:100%;
      border-radius:14px;
      border:1px solid rgba(148,163,184,.65);
      background:rgba(15,23,42,.86);
      padding:.7rem .9rem;
      font-size:.85rem;
      color:#e5e7eb;
      outline:none;
      transition:border-color .15s, box-shadow .15s, background .15s;
    }
    .field-input::placeholder,
    .field-textarea::placeholder{
      color:#6b7280;
    }
    .field-input:focus,
    .field-textarea:focus,
    .ui-select:focus{
      border-color:var(--accent);
      box-shadow:0 0 0 1px rgba(34,227,196,.7);
      background:rgba(15,23,42,1);
    }
    .field-textarea{
      resize:none;
      min-height:110px;
    }
    .ui-select option{
      background:#020617;
      color:#f9fafb;
    }

    .type-toggle-group{
      display:flex;
      flex-wrap:wrap;
      gap:.5rem;
    }
    .type-pill{
      border-radius:999px;
      padding:.5rem .9rem;
      font-size:.78rem;
      border:1px solid rgba(148,163,184,.6);
      background:rgba(15,23,42,.9);
      cursor:pointer;
      display:inline-flex;
      align-items:center;
      gap:.4rem;
      color:#e5e7eb;
      transition:background .15s, border-color .15s, color .15s, box-shadow .15s;
    }
    .type-pill span.dot{
      width:8px;height:8px;border-radius:999px;
      background:#6b7280;
    }
    .type-pill.active{
      border-color:var(--accent);
      background:rgba(15,118,110,.9);
      box-shadow:0 0 18px rgba(34,211,238,.5);
      color:#ecfeff;
    }
    .type-pill.active span.dot{
      background:#22e3c4;
    }

    /* ------- IMAGEN / PORTADA -------- */
    .image-drop{
      border-radius:18px;
      border:1px solid rgba(148,163,184,.7);
      background:radial-gradient(circle at top,#1f2937,#020617 80%);
      padding:1.1rem 1rem 1.3rem;
      font-size:.8rem;
      color:#9ca3af;
      box-shadow:0 18px 40px rgba(0,0,0,.85);
      position:relative;
      overflow:hidden;
    }

    .image-drop-top{
      display:flex;
      justify-content:space-between;
      align-items:center;
      gap:.5rem;
      margin-bottom:.8rem;
    }
    .image-drop-pill{
      padding:.22rem .7rem;
      border-radius:999px;
      border:1px solid rgba(148,163,184,.7);
      background:rgba(15,23,42,.9);
      font-size:.7rem;
      text-transform:uppercase;
      letter-spacing:.09em;
      color:#e5e7eb;
      display:inline-flex;
      align-items:center;
      gap:.4rem;
    }
    .image-drop-pill-dot{
      width:7px;height:7px;
      border-radius:999px;
      background:#fb7185;
      box-shadow:0 0 12px rgba(248,113,113,.9);
    }

    .image-preview-box{
      position:relative;
      border-radius:16px;
      overflow:hidden;
      height:150px;
      margin-bottom:.85rem;
      background:
        linear-gradient(135deg,rgba(15,23,42,1),rgba(30,64,175,1)),
        url("https://images.pexels.com/photos/1190297/pexels-photo-1190297.jpeg?auto=compress&cs=tinysrgb&w=1200");
      background-size:cover;
      background-position:center;
      box-shadow:0 16px 30px rgba(0,0,0,.9);
      transform:translateZ(0);
    }
    .image-preview-box::after{
      content:"";
      position:absolute;
      inset:0;
      background:linear-gradient(to top,rgba(15,23,42,.9),rgba(15,23,42,.2));
    }
    .image-preview-inner{
      position:absolute;
      inset:0;
      padding:.9rem 1rem;
      display:flex;
      flex-direction:column;
      justify-content:space-between;
      pointer-events:none;
    }
    .image-preview-badge{
      align-self:flex-start;
      padding:.18rem .7rem;
      border-radius:999px;
      background:rgba(15,23,42,.82);
      border:1px solid rgba(148,163,184,.65);
      font-size:.65rem;
      letter-spacing:.08em;
      text-transform:uppercase;
      color:#e5e7eb;
    }
    .image-preview-title{
      font-weight:800;
      font-size:1rem;
      letter-spacing:.05em;
      text-transform:uppercase;
      color:#e5e7eb;
      text-shadow:0 2px 12px rgba(0,0,0,.95);
    }
    .image-preview-meta{
      display:flex;
      align-items:center;
      justify-content:space-between;
      gap:.5rem;
      font-size:.7rem;
      color:#d1fae5;
    }
    .image-preview-meta span{
      display:flex;
      align-items:center;
      gap:.25rem;
    }
    .image-preview-meta-dot{
      width:6px;height:6px;border-radius:999px;
      background:#22e3c4;
      box-shadow:0 0 10px rgba(34,227,196,.9);
    }

    .image-drop-helper{
      font-size:.72rem;
      color:#9ca3af;
      margin-bottom:.4rem;
    }
    .image-drop-helper strong{
      color:#e5e7eb;
      font-weight:600;
    }

    .image-drop-input-wrapper{
      position:relative;
      margin-top:.3rem;
    }
    .image-drop-input-wrapper .field-input{
      padding-left:2.2rem;
      font-size:.8rem;
    }
    .image-drop-input-icon{
      position:absolute;
      left:.7rem;
      top:50%;
      transform:translateY(-50%);
      font-size:.85rem;
      opacity:.8;
    }

    .image-chip-row{
      display:flex;
      flex-wrap:wrap;
      gap:.35rem;
      margin-top:.7rem;
      font-size:.67rem;
    }
    .image-chip{
      padding:.2rem .6rem;
      border-radius:999px;
      border:1px solid rgba(148,163,184,.6);
      background:rgba(15,23,42,.85);
      color:#cbd5f5;
    }

    .image-preview-box.has-image{
      animation:preview-pop .35s ease-out;
    }
    @keyframes preview-pop{
      0%{transform:scale(.97);opacity:.4;}
      100%{transform:scale(1);opacity:1;}
    }

    /* --- AFOROS / LOCALIDADES (PASO 3) --- */
    .lp-step-pane{display:none;}
    .lp-step-pane.active{display:block;}

    .aforos-grid{
      display:grid;
      gap:1.4rem;
      grid-template-columns:minmax(0,1.1fr) minmax(0,1.4fr);
      align-items:flex-start;
      margin-top:.4rem;
    }
    @media (max-width:900px){
      .aforos-grid{grid-template-columns:1fr;}
    }

    .aforo-diagram{
      border-radius:18px;
      padding:1.2rem 1rem 1.3rem;
      background:radial-gradient(circle at top,#111827,#020617 70%);
      border:1px solid rgba(148,163,184,.45);
      box-shadow:0 18px 40px rgba(0,0,0,.8);
      font-size:.78rem;
    }
    .aforo-stage{
      width:70%;
      margin:0 auto .8rem;
      padding:.35rem .7rem;
      border-radius:8px;
      text-align:center;
      background:#e5e7eb;
      color:#020617;
      font-weight:700;
      font-size:.7rem;
      letter-spacing:.06em;
    }
    .aforo-bands{
      display:flex;
      flex-direction:column;
      gap:.45rem;
      margin-bottom:1rem;
    }
    .aforo-band{
      position:relative;
      height:42px;
      margin:0 auto;
      max-width:260px;
      display:flex;
      align-items:center;
      justify-content:center;
      color:#f9fafb;
      font-weight:700;
      font-size:.8rem;
      text-transform:uppercase;
      letter-spacing:.04em;
      clip-path:polygon(6% 0,94% 0,100% 100%,0 100%);
      box-shadow:0 10px 25px rgba(15,23,42,.9);
    }
    .aforo-band-1{background:linear-gradient(135deg,#2563eb,#1d4ed8);}
    .aforo-band-2{background:linear-gradient(135deg,#0ea5e9,#22c55e);}
    .aforo-band-3{background:linear-gradient(135deg,#16a34a,#22c55e);}
    .aforo-band-4{background:linear-gradient(135deg,#0f172a,#1e293b);}

    .aforo-band-label{
      text-shadow:0 2px 6px rgba(15,23,42,.95);
    }

    .aforo-legend-title{
      font-size:.7rem;
      text-transform:uppercase;
      letter-spacing:.08em;
      color:#9ca3af;
      margin-bottom:.35rem;
    }
    .aforo-legend-table{
      width:100%;
      border-collapse:collapse;
      font-size:.7rem;
      color:#e5e7eb;
    }
    .aforo-legend-table th{
      text-align:left;
      padding:.25rem .1rem;
      font-weight:600;
      color:#9ca3af;
    }
    .aforo-legend-table td{
      padding:.22rem .1rem;
      vertical-align:middle;
      border-top:1px solid rgba(30,64,175,.35);
    }
    .aforo-color-pill{
      width:34px;
      height:6px;
      border-radius:999px;
      display:inline-block;
    }
    .aforo-color-1{background:linear-gradient(90deg,#2563eb,#1d4ed8);}
    .aforo-color-2{background:linear-gradient(90deg,#0ea5e9,#22c55e);}
    .aforo-color-3{background:linear-gradient(90deg,#16a34a,#22c55e);}
    .aforo-color-4{background:linear-gradient(90deg,#0f172a,#1e293b);}

    .zones-table{
      width:100%;
      border-collapse:separate;
      border-spacing:0 .4rem;
      font-size:.78rem;
    }
    .zones-table thead th{
      text-align:left;
      padding-bottom:.15rem;
      color:#9ca3af;
      font-weight:600;
    }
    .zones-table tbody tr td{
      padding:.15rem .3rem .15rem 0;
      vertical-align:top;
    }
    .zone-name-input,
    .zone-cap-input,
    .zone-price-input{
      font-size:.78rem;
      padding:.55rem .75rem;
      border-radius:999px;
    }

    .zones-actions{
      display:flex;
      flex-wrap:wrap;
      gap:.4rem;
      margin-top:.5rem;
      justify-content:flex-end;
    }

    .btn-small{
      padding:.35rem .8rem;
      border-radius:999px;
      border:1px solid rgba(148,163,184,.7);
      background:rgba(15,23,42,.85);
      font-size:.72rem;
      color:#e5e7eb;
      display:inline-flex;
      align-items:center;
      gap:.3rem;
      cursor:pointer;
    }
    .btn-small span{
      font-size:.8rem;
    }

    .pulse-highlight{
      animation:pulse-highlight 0.6s ease-out;
    }
    @keyframes pulse-highlight{
      0%{box-shadow:0 0 0 0 rgba(34,227,196,.7);}
      100%{box-shadow:0 0 0 8px rgba(34,227,196,0);}
    }

    .btn-primary{
      background:linear-gradient(120deg,var(--accent2),var(--accent));
      padding:.7rem 1.5rem;
      border-radius:999px;
      font-size:.9rem;
      font-weight:700;
      border:none;
      cursor:pointer;
      display:inline-flex;
      align-items:center;
      gap:.45rem;
      box-shadow:0 16px 30px rgba(76,29,149,.9);
      color:#f9fafb;
    }
    .btn-primary[disabled]{
      opacity:.5;
      cursor:not-allowed;
      box-shadow:none;
    }
    .btn-secondary{
      padding:.55rem 1.1rem;
      border-radius:999px;
      border:1px solid rgba(148,163,184,.7);
      background:rgba(15,23,42,.85);
      font-size:.85rem;
      color:#e5e7eb;
      display:inline-flex;
      align-items:center;
      gap:.35rem;
      text-decoration:none;
    }

    .ripple{
      position:relative;
      overflow:hidden;
    }
    .ripple span.fx{
      position:absolute;
      border-radius:50%;
      transform:scale(0);
      opacity:.35;
      background:radial-gradient(circle,var(--accent2),var(--accent));
      pointer-events:none;
      animation:ripple .6s ease-out forwards;
    }
    @keyframes ripple{
      to{transform:scale(2.5);opacity:0;}
    }
  </style>
</head>

<body class="text-white">
  <%@ include file="../Includes/nav_base.jspf" %>

  <section class="lp-hero">
    <div class="lp-hero-inner">

      <!-- PASOS -->
      <div class="lp-steps" id="stepsNav">
        <div class="lp-step lp-step--active" data-step="1">
          <div class="lp-step-pill">1</div>
          <span class="lp-step-label">Información básica</span>
          <span class="lp-step-sub">Nombre y categoría</span>
        </div>
        <div class="lp-step" data-step="2">
          <div class="lp-step-pill">2</div>
          <span class="lp-step-label">Fecha y lugar</span>
          <span class="lp-step-sub">Ciudad y horario</span>
        </div>
        <div class="lp-step" data-step="3">
          <div class="lp-step-pill">3</div>
          <span class="lp-step-label">Capacidad y tarifas</span>
          <span class="lp-step-sub">Aforos y precios</span>
        </div>
        <div class="lp-step" data-step="4">
          <div class="lp-step-pill">4</div>
          <span class="lp-step-label">Portada y resumen</span>
          <span class="lp-step-sub">Descripción e imagen</span>
        </div>
      </div>

      <!-- CARD -->
      <div class="lp-card">
        <div class="flex items-start justify-between gap-3 mb-6">
          <div>
            <div class="lp-chip mb-2" id="chipStep">
              <span class="lp-chip-dot"></span>
              Paso 1 · Información básica
            </div>
            <h1 class="text-2xl" id="titleStep">Crea tu nuevo evento</h1>
            <p class="text-sm text-slate-300 mt-1" id="subtitleStep">
              Completa los datos principales. Luego podrás ajustar horarios, capacidad y portada.
            </p>
          </div>
        </div>

        <form
          id="eventForm"
          action="<%= request.getContextPath() %>/Control/ct_event_create.jsp"
          method="post"
        >
          <!-- PASO 1 -->
          <div class="lp-step-pane active" data-step-panel="1">
            <div style="display:flex;flex-direction:column;gap:1.2rem;">
              <div>
                <label class="field-label">
                  Nombre del evento
                  <span class="helper">(obligatorio)</span>
                </label>
                <input
                  name="title"
                  required
                  maxlength="120"
                  placeholder="Ej. Concierto LivePass Buga Night"
                  class="field-input"
                />
              </div>

              <div class="grid" style="gap:1.1rem;grid-template-columns:repeat(auto-fit,minmax(0, min(260px,100%)));">
                <div>
                  <label class="field-label">
                    Categoría del evento
                    <span class="helper">para ordenar en la web</span>
                  </label>
                  <select name="category" class="ui-select">
                    <option value="">Selecciona una categoría</option>
                    <option value="MUSICA">Concierto / Música</option>
                    <option value="DEPORTES">Deportes</option>
                    <option value="TEATRO">Teatro / Artes escénicas</option>
                    <option value="CONFERENCIA">Conferencias</option>
                    <option value="FESTIVAL">Festivales</option>
                    <option value="OTROS">Otros</option>
                  </select>
                </div>

                <div>
                  <label class="field-label">
                    Género / temática
                    <span class="helper">visible en la ficha</span>
                  </label>
                  <input
                    name="genre"
                    placeholder="Reggaetón, Rock, Conferencia de negocios..."
                    class="field-input"
                  />
                </div>
              </div>

              <div>
                <label class="field-label">
                  Tipo de evento
                  <span class="helper">elige una opción</span>
                </label>
                <div class="type-toggle-group" id="typeToggleGroup">
                  <button type="button" class="type-pill active" data-value="PRESENCIAL">
                    <span class="dot"></span> Presencial
                  </button>
                  <button type="button" class="type-pill" data-value="VIRTUAL">
                    <span class="dot"></span> Virtual
                  </button>
                  <button type="button" class="type-pill" data-value="HIBRIDO">
                    <span class="dot"></span> Híbrido
                  </button>
                </div>
                <input type="hidden" name="event_type" id="eventTypeHidden" value="PRESENCIAL" />
              </div>
            </div>
          </div>

          <!-- PASO 2 -->
          <div class="lp-step-pane" data-step-panel="2">
            <div style="display:flex;flex-direction:column;gap:1.2rem;">
              <div class="grid" style="gap:1.1rem;grid-template-columns:repeat(auto-fit,minmax(0, min(260px,100%)));">
                <div>
                  <label class="field-label">Lugar (venue)</label>
                  <input
                    name="venue"
                    required
                    placeholder="Ej. Coliseo Mayor, Teatro Municipal..."
                    class="field-input"
                  />
                </div>
                <div>
                  <label class="field-label">Ciudad</label>
                  <input
                    name="city"
                    required
                    placeholder="Buga, Cali, Medellín..."
                    class="field-input"
                  />
                </div>
              </div>

              <div>
                <label class="field-label">
                  Fecha y hora
                  <span class="helper">inicio del evento</span>
                </label>
                <input
                  type="datetime-local"
                  name="date_time"
                  required
                  class="field-input"
                />
              </div>
            </div>
          </div>

          <!-- PASO 3: CAPACIDAD + AFOROS -->
          <div class="lp-step-pane" data-step-panel="3">
            <div style="display:flex;flex-direction:column;gap:1.2rem;">

              <!-- Capacidad total + precio base -->
              <div class="grid" style="gap:1.1rem;grid-template-columns:repeat(auto-fit,minmax(0, min(260px,100%)));">
                <div>
                  <label class="field-label">
                    Capacidad total
                    <span class="helper">puedes calcularla desde los aforos</span>
                  </label>
                  <input
                    type="number"
                    name="capacity"
                    id="capacityTotal"
                    min="1"
                    value="100"
                    required
                    class="field-input"
                  />
                </div>
                <div>
                  <label class="field-label">
                    Precio general (COP)
                    <span class="helper">referencia o entrada más económica</span>
                  </label>
                  <input
                    name="price"
                    required
                    placeholder="Ej. 25000"
                    class="field-input"
                  />
                </div>
              </div>

              <!-- Localidades / aforos -->
              <div>
                <label class="field-label">
                  Localidades y aforos
                  <span class="helper">define capacidad y precio por sección</span>
                </label>

                <div class="aforos-grid">
                  <!-- Diagrama visual -->
                  <div class="aforo-diagram">
                    <div class="aforo-stage">ESCENARIO</div>
                    <div class="aforo-bands">
                      <div class="aforo-band aforo-band-1" data-zone="1">
                        <span class="aforo-band-label" data-zone-label-band="1">PLATEA A</span>
                      </div>
                      <div class="aforo-band aforo-band-2" data-zone="2">
                        <span class="aforo-band-label" data-zone-label-band="2">PLATEA B</span>
                      </div>
                      <div class="aforo-band aforo-band-3" data-zone="3">
                        <span class="aforo-band-label" data-zone-label-band="3">GENERAL</span>
                      </div>
                      <div class="aforo-band aforo-band-4" data-zone="4">
                        <span class="aforo-band-label" data-zone-label-band="4">VIP</span>
                      </div>
                    </div>

                    <div>
                      <div class="aforo-legend-title">Resumen por localidad (demo visual)</div>
                      <table class="aforo-legend-table">
                        <thead>
                          <tr>
                            <th>Localidad</th>
                            <th>Color</th>
                          </tr>
                        </thead>
                        <tbody>
                          <tr>
                            <td><span data-zone-label-legend="1">PLATEA A</span></td>
                            <td><span class="aforo-color-pill aforo-color-1"></span></td>
                          </tr>
                          <tr>
                            <td><span data-zone-label-legend="2">PLATEA B</span></td>
                            <td><span class="aforo-color-pill aforo-color-2"></span></td>
                          </tr>
                          <tr>
                            <td><span data-zone-label-legend="3">GENERAL</span></td>
                            <td><span class="aforo-color-pill aforo-color-3"></span></td>
                          </tr>
                          <tr>
                            <td><span data-zone-label-legend="4">VIP</span></td>
                            <td><span class="aforo-color-pill aforo-color-4"></span></td>
                          </tr>
                        </tbody>
                      </table>
                    </div>
                  </div>

                  <!-- Configuración de zonas -->
                  <div>
                    <table class="zones-table">
                      <thead>
                        <tr>
                          <th>Localidad</th>
                          <th>Capacidad</th>
                          <th>Precio (COP)</th>
                        </tr>
                      </thead>
                      <tbody id="zonesList">
                        <tr data-zone-row="1">
                          <td>
                            <input
                              name="zone_name[]"
                              data-zone="1"
                              class="field-input zone-name-input"
                              placeholder="PLATEA A"
                              value="PLATEA A"
                            />
                          </td>
                          <td>
                            <input
                              type="number"
                              min="0"
                              name="zone_capacity[]"
                              data-zone="1"
                              class="field-input zone-cap-input"
                              placeholder="Ej. 3000"
                            />
                          </td>
                          <td>
                            <input
                              name="zone_price[]"
                              data-zone="1"
                              class="field-input zone-price-input"
                              placeholder="Ej. 150000"
                            />
                          </td>
                        </tr>

                        <tr data-zone-row="2">
                          <td>
                            <input
                              name="zone_name[]"
                              data-zone="2"
                              class="field-input zone-name-input"
                              placeholder="PLATEA B"
                              value="PLATEA B"
                            />
                          </td>
                          <td>
                            <input
                              type="number"
                              min="0"
                              name="zone_capacity[]"
                              data-zone="2"
                              class="field-input zone-cap-input"
                              placeholder="Ej. 2800"
                            />
                          </td>
                          <td>
                            <input
                              name="zone_price[]"
                              data-zone="2"
                              class="field-input zone-price-input"
                              placeholder="Ej. 130000"
                            />
                          </td>
                        </tr>

                        <tr data-zone-row="3">
                          <td>
                            <input
                              name="zone_name[]"
                              data-zone="3"
                              class="field-input zone-name-input"
                              placeholder="GENERAL"
                              value="GENERAL"
                            />
                          </td>
                          <td>
                            <input
                              type="number"
                              min="0"
                              name="zone_capacity[]"
                              data-zone="3"
                              class="field-input zone-cap-input"
                              placeholder="Ej. 2000"
                            />
                          </td>
                          <td>
                            <input
                              name="zone_price[]"
                              data-zone="3"
                              class="field-input zone-price-input"
                              placeholder="Ej. 90000"
                            />
                          </td>
                        </tr>

                        <tr data-zone-row="4">
                          <td>
                            <input
                              name="zone_name[]"
                              data-zone="4"
                              class="field-input zone-name-input"
                              placeholder="VIP"
                              value="VIP"
                            />
                          </td>
                          <td>
                            <input
                              type="number"
                              min="0"
                              name="zone_capacity[]"
                              data-zone="4"
                              class="field-input zone-cap-input"
                              placeholder="Ej. 1000"
                            />
                          </td>
                          <td>
                            <input
                              name="zone_price[]"
                              data-zone="4"
                              class="field-input zone-price-input"
                              placeholder="Ej. 180000"
                            />
                          </td>
                        </tr>
                      </tbody>
                    </table>

                    <div class="zones-actions">
                      <button type="button" class="btn-small" id="btnCalcCap">
                        <span>⇱</span> Calcular capacidad total
                      </button>
                      <button type="button" class="btn-small" id="btnAddZone">
                        <span>＋</span> Añadir localidad
                      </button>
                    </div>

                    <p style="font-size:0.7rem;color:#94a3b8;margin-top:.5rem;">
                      Los datos de localidades se envían como listas:
                      <code>zone_name[]</code>, <code>zone_capacity[]</code> y <code>zone_price[]</code>.
                    </p>
                  </div>
                </div>
              </div>

              <div>
                <label class="field-label">Estado inicial</label>
                <select name="status" class="ui-select">
                  <option value="BORRADOR">Borrador (no visible)</option>
                  <option value="PENDIENTE">Enviar a revisión</option>
                </select>
              </div>
            </div>
          </div>

          <!-- PASO 4 -->
          <div class="lp-step-pane" data-step-panel="4">
            <div style="display:flex;flex-direction:column;gap:1.2rem;">
              <div>
                <label class="field-label">
                  Descripción del evento
                  <span class="helper">máx. 500 caracteres</span>
                </label>
                <textarea
                  name="description"
                  maxlength="500"
                  rows="4"
                  placeholder="Cuenta en qué consiste el evento, horarios, invitados especiales, recomendaciones para el asistente, etc."
                  class="field-textarea"
                ></textarea>
                <p style="font-size:0.7rem;color:#94a3b8;margin-top:.25rem;">
                  Este texto será visible en la página pública del evento.
                </p>
              </div>

              <div class="grid" style="gap:1.1rem;grid-template-columns:repeat(auto-fit,minmax(0, min(260px,100%)));">
                <!-- IMAGEN BONITA -->
                <div>
                  <label class="field-label">
                    Portada del evento
                    <span class="helper">hazla irresistible ✨</span>
                  </label>
                  <div class="image-drop">
                    <div class="image-drop-top">
                      <div class="image-drop-pill">
                        <span class="image-drop-pill-dot"></span>
                        Vista previa en tiempo real
                      </div>
                      <span style="font-size:.7rem;color:#9ca3af;">Lo primero que verá tu público</span>
                    </div>

                    <div class="image-preview-box" id="imagePreviewBox">
                      <div class="image-preview-inner">
                        <span class="image-preview-badge">LIVEPASS · BUGA</span>
                        <div>
                          <div class="image-preview-title" id="previewTitleText">
                            Tu evento épico
                          </div>
                          <div class="image-preview-meta">
                            <span>
                              <span class="image-preview-meta-dot"></span>
                              <span id="previewCityText">Buga, Colombia</span>
                            </span>
                            <span>Viernes 9:00 p.m.</span>
                          </div>
                        </div>
                      </div>
                    </div>

                    <p class="image-drop-helper">
                      <strong>Tip:</strong> usa una foto con público, luces o escenario. Debe transmitir
                      energía y ganas de estar ahí.
                    </p>

                    <div class="image-drop-input-wrapper">
                      <span class="image-drop-input-icon">🔗</span>
                      <input
                        id="imageInput"
                        name="image"
                        placeholder="Pega aquí la URL de tu imagen (JPG o PNG)"
                        class="field-input"
                      />
                    </div>

                    <div class="image-chip-row">
                      <span class="image-chip">Recomendado: 1600 × 900 px</span>
                      <span class="image-chip">Peso máx. aprox. 1 MB</span>
                      <span class="image-chip">Evita textos pequeños en la imagen</span>
                    </div>
                  </div>
                </div>

                <!-- TEXTO ALT -->
                <div>
                  <label class="field-label">
                    Texto alternativo (accesibilidad)
                    <span class="helper">opcional</span>
                  </label>
                  <textarea
                    name="image_alt"
                    rows="3"
                    placeholder="Ej. Fotografía de un concierto con luces azules y público levantando las manos."
                    class="field-textarea"
                  ></textarea>
                  <p style="font-size:0.7rem;color:#94a3b8;margin-top:.25rem;">
                    Útil para lectores de pantalla y cuando la imagen no carga.
                  </p>
                </div>
              </div>
            </div>
          </div>

          <!-- BOTONES NAVEGACIÓN -->
          <div style="display:flex;flex-wrap:wrap;gap:.75rem;margin-top:1.8rem;align-items:center;">
            <button type="button" id="btnBack" class="btn-secondary ripple" disabled>
              ← Volver
            </button>

            <button type="button" id="btnNext" class="btn-primary ripple">
              Siguiente paso →
            </button>

            <button type="submit" id="btnSubmit" class="btn-primary ripple" style="display:none;">
              Crear evento
            </button>

            <a
              href="<%= request.getContextPath() %>/Vista/EventosOrganizador.jsp"
              class="btn-secondary"
              style="margin-left:auto;"
            >
              Cancelar
            </a>
          </div>
        </form>
      </div>
    </div>
  </section>

  <script>
    // ripple
    document.addEventListener('click', function(e){
      const btn = e.target.closest('.ripple');
      if(!btn) return;
      const rect = btn.getBoundingClientRect();
      const fx = document.createElement('span');
      fx.className = 'fx';
      const size = Math.max(rect.width, rect.height);
      fx.style.width = fx.style.height = size + 'px';
      fx.style.left  = (e.clientX - rect.left - size/2) + 'px';
      fx.style.top   = (e.clientY - rect.top  - size/2) + 'px';
      btn.appendChild(fx);
      setTimeout(() => fx.remove(), 650);
    });

    // toggle tipo de evento
    (function(){
      const group  = document.getElementById('typeToggleGroup');
      const hidden = document.getElementById('eventTypeHidden');
      if(!group || !hidden) return;
      group.querySelectorAll('.type-pill').forEach(btn => {
        btn.addEventListener('click', () => {
          group.querySelectorAll('.type-pill').forEach(b => b.classList.remove('active'));
          btn.classList.add('active');
          hidden.value = btn.dataset.value || 'PRESENCIAL';
        });
      });
    })();

    // --- AFOROS: sincronizar nombres, añadir filas y calcular capacidad ---
    (function(){
      function syncZoneLabels(zone, value, placeholder){
        const text = value || placeholder || '';
        const band = document.querySelector('[data-zone-label-band="'+zone+'"]');
        const leg  = document.querySelector('[data-zone-label-legend="'+zone+'"]');
        if(band){ band.textContent = text || '—'; }
        if(leg){ leg.textContent  = text || '—'; }
      }

      // sincronizar nombres iniciales
      document.querySelectorAll('.zone-name-input').forEach(function(inp){
        const zone = inp.getAttribute('data-zone');
        const update = function(){
          syncZoneLabels(zone, inp.value, inp.getAttribute('placeholder'));
        };
        inp.addEventListener('input', update);
        update();
      });

      // calcular capacidad total desde zonas
      const btnCalcCap = document.getElementById('btnCalcCap');
      const capTotal   = document.getElementById('capacityTotal');

      if(btnCalcCap && capTotal){
        btnCalcCap.addEventListener('click', function(){
          let total = 0;
          document.querySelectorAll('.zone-cap-input').forEach(function(inp){
            const v = parseInt(inp.value, 10);
            if(!isNaN(v) && v > 0){ total += v; }
          });
          capTotal.value = total || '';
          if(total > 0){
            capTotal.classList.add('pulse-highlight');
            setTimeout(function(){ capTotal.classList.remove('pulse-highlight'); }, 600);
          }
        });
      }

      // añadir nueva localidad
      const btnAddZone = document.getElementById('btnAddZone');
      const zonesList  = document.getElementById('zonesList');

      if(btnAddZone && zonesList){
        btnAddZone.addEventListener('click', function(){
          const rows = zonesList.querySelectorAll('tr');
          const nextIndex = rows.length + 1;
          const tr = document.createElement('tr');
          tr.setAttribute('data-zone-row', nextIndex);

          tr.innerHTML = ''
            + '<td>'
            + '  <input name="zone_name[]" data-zone="'+nextIndex+'"'
            + '         class="field-input zone-name-input"'
            + '         placeholder="Localidad '+nextIndex+'" />'
            + '</td>'
            + '<td>'
            + '  <input type="number" min="0" name="zone_capacity[]"'
            + '         data-zone="'+nextIndex+'"'
            + '         class="field-input zone-cap-input"'
            + '         placeholder="Ej. 1000" />'
            + '</td>'
            + '<td>'
            + '  <input name="zone_price[]" data-zone="'+nextIndex+'"'
            + '         class="field-input zone-price-input"'
            + '         placeholder="Ej. 120000" />'
            + '</td>';

          zonesList.appendChild(tr);

          const inpName = tr.querySelector('.zone-name-input');
          const update = function(){
            syncZoneLabels(nextIndex, inpName.value, inpName.getAttribute('placeholder'));
          };
          inpName.addEventListener('input', update);
          update();
        });
      }
    })();

    // wizard de pasos
    (function(){
      const TOTAL_STEPS = 4;
      let currentStep = 1;

      const panes   = document.querySelectorAll('.lp-step-pane');
      const steps   = document.querySelectorAll('.lp-step');
      const btnBack = document.getElementById('btnBack');
      const btnNext = document.getElementById('btnNext');
      const btnSub  = document.getElementById('btnSubmit');
      const chip    = document.getElementById('chipStep');
      const title   = document.getElementById('titleStep');
      const subtitle= document.getElementById('subtitleStep');

      const copy = {
        1: {
          chip: 'Paso 1 · Información básica',
          title:'Crea tu nuevo evento',
          sub:'Nombre, categoría y tipo de evento.'
        },
        2: {
          chip: 'Paso 2 · Fecha y ubicación',
          title:'Define dónde y cuándo',
          sub:'Configura la ciudad, lugar y fecha de inicio.'
        },
        3: {
          chip: 'Paso 3 · Capacidad y tarifas',
          title:'Configura los aforos y precios',
          sub:'Define capacidad total y precio por localidad.'
        },
        4: {
          chip: 'Paso 4 · Portada y resumen',
          title:'Haz que tu evento luzca increíble',
          sub:'Añade descripción, imagen principal y texto alternativo.'
        }
      };

      function updateUI(){
        panes.forEach(p => {
          const step = parseInt(p.getAttribute('data-step-panel'),10);
          p.classList.toggle('active', step === currentStep);
        });

        steps.forEach(s => {
          const step = parseInt(s.getAttribute('data-step'),10);
          s.classList.toggle('lp-step--active', step === currentStep);
          s.classList.toggle('lp-step--done', step < currentStep);
        });

        chip.innerHTML = '<span class="lp-chip-dot"></span> ' + copy[currentStep].chip;
        title.textContent    = copy[currentStep].title;
        subtitle.textContent = copy[currentStep].sub;

        btnBack.disabled = currentStep === 1;
        if(currentStep === TOTAL_STEPS){
          btnNext.style.display = 'none';
          btnSub.style.display  = 'inline-flex';
        }else{
          btnNext.style.display = 'inline-flex';
          btnSub.style.display  = 'none';
        }
      }

      function validateCurrentStep(){
        const pane = document.querySelector('.lp-step-pane[data-step-panel="'+currentStep+'"]');
        if(!pane) return true;
        const fields = pane.querySelectorAll('input, select, textarea');
        for(const f of fields){
          if(typeof f.checkValidity === 'function' && !f.checkValidity()){
            f.reportValidity();
            return false;
          }
        }
        return true;
      }

      btnNext.addEventListener('click', () => {
        if(!validateCurrentStep()) return;
        if(currentStep < TOTAL_STEPS){
          currentStep++;
          updateUI();
        }
      });

      btnBack.addEventListener('click', () => {
        if(currentStep > 1){
          currentStep--;
          updateUI();
        }
      });

      updateUI();
    })();

    // Vista previa de portada en vivo
    (function(){
      const input   = document.getElementById('imageInput');
      const box     = document.getElementById('imagePreviewBox');
      const titleEl = document.getElementById('previewTitleText');
      const cityEl  = document.getElementById('previewCityText');
      const titleSrc = document.querySelector('input[name="title"]');
      const citySrc  = document.querySelector('input[name="city"]');

      if(!input || !box) return;

      function updateBg(){
        const url = (input.value || "").trim();
        if(url){
          box.style.backgroundImage =
            'linear-gradient(135deg,rgba(15,23,42,1),rgba(15,23,42,.1)), url(\"'+url.replace(/"/g,'')+'\")';
          box.classList.add('has-image');
        }else{
          box.style.backgroundImage =
            'linear-gradient(135deg,rgba(15,23,42,1),rgba(30,64,175,1)), ' +
            'url(\"https://images.pexels.com/photos/1190297/pexels-photo-1190297.jpeg?auto=compress&cs=tinysrgb&w=1200\")';
          box.classList.remove('has-image');
        }
      }

      function syncTitle(){
        if(titleSrc && titleSrc.value.trim()){
          titleEl.textContent = titleSrc.value.trim();
        }else{
          titleEl.textContent = 'Tu evento épico';
        }
      }

      function syncCity(){
        if(citySrc && citySrc.value.trim()){
          cityEl.textContent = citySrc.value.trim();
        }else{
          cityEl.textContent = 'Buga, Colombia';
        }
      }

      input.addEventListener('input', updateBg);
      if(titleSrc) titleSrc.addEventListener('input', syncTitle);
      if(citySrc)  citySrc.addEventListener('input', syncCity);

      updateBg();
      syncTitle();
      syncCity();
    })();
  </script>
</body>
</html>
