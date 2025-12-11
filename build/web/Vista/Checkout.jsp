}<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.EventDAO, utils.Event" %>
<%@ page import="java.math.BigDecimal, java.math.RoundingMode, java.text.NumberFormat, java.util.Locale" %>
<%@ page import="utils.Conexion, java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>

<%
  // --- Guard de sesión ---
  Integer uid = (Integer) session.getAttribute("userId");
  if (uid == null) {
    response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp");
    return;
  }

  // --- Parámetros iniciales provenientes del flujo anterior ---
  int eventId = 0, qty = 1;
  int ticketTypeId = 0; // aforo elegido (si viene)
  String coupon = request.getParameter("coupon");

  try { eventId      = Integer.parseInt(request.getParameter("eventId")); } catch(Exception ignore){}
  try { qty          = Math.max(1, Integer.parseInt(request.getParameter("qty"))); } catch(Exception ignore){}
  try { ticketTypeId = Integer.parseInt(request.getParameter("ticketTypeId")); } catch(Exception ignore){}

  if (eventId <= 0) {
    response.sendRedirect(request.getContextPath()+"/Vista/PaginaPrincipal.jsp");
    return;
  }

  // --- Cargar evento ---
  Event ev = new EventDAO().findById(eventId).orElse(null);
  if (ev == null) {
    response.sendRedirect(request.getContextPath()+"/Vista/PaginaPrincipal.jsp");
    return;
  }

  // Disponibilidad general del evento (sumatoria de aforos - vendidos)
  int avail = Math.max(0, ev.getAvailability());
  if (avail > 0 && qty > avail) qty = avail;

  // === Cargar tipo de ticket / aforo elegido (UNITARIO INICIAL) ===
  String ticketTypeName = "General";
  int capacityTotal = 0;
  BigDecimal unit = BigDecimal.ZERO; // precio real del aforo

  try {
      Conexion cx = new Conexion();
      String sql;
      if (ticketTypeId > 0) {
          // Si ya viene un tipo elegido, usamos ese
          sql = "SELECT id, name, capacity, price " +
                "FROM ticket_types WHERE id = ? LIMIT 1";
      } else {
          // Si no, tomamos el más barato del evento
          sql = "SELECT id, name, capacity, price " +
                "FROM ticket_types " +
                "WHERE id_event = ? " +
                "ORDER BY price ASC " +
                "LIMIT 1";
      }

      try (Connection cn = cx.getConnection();
           PreparedStatement ps = cx.getConnection().prepareStatement(sql)) {

          if (ticketTypeId > 0) {
              ps.setInt(1, ticketTypeId);
          } else {
              ps.setInt(1, eventId);
          }

          try (ResultSet rs = ps.executeQuery()) {
              if (rs.next()) {
                  ticketTypeId   = rs.getInt("id");  // nos aseguramos de tener el id correcto
                  String n       = rs.getString("name");
                  ticketTypeName = (n != null && !n.isEmpty()) ? n : ticketTypeName;
                  capacityTotal  = rs.getInt("capacity");
                  unit           = rs.getBigDecimal("price");   // precio del aforo
              }
          }
      }
      cx.cerrarConexion();
  } catch (Exception e) {
      e.printStackTrace();
  }

  // Si por alguna razón no hay ticket_types, usamos el precio del evento como fallback
  if (unit == null || unit.compareTo(BigDecimal.ZERO) <= 0) {
      unit = (ev.getPriceValue()!=null) ? ev.getPriceValue() : BigDecimal.ZERO;
  }

  // === Cálculos iniciales (sin fees extra, sólo subtotal - descuento) ===
  BigDecimal subtotal = unit.multiply(BigDecimal.valueOf(qty));

  // Cupón demo (aplicado inicialmente sólo para mostrar algo coherente)
  BigDecimal discount = BigDecimal.ZERO;
  boolean couponValid = false;
  if (coupon != null && !coupon.trim().isEmpty()) {
    String c = coupon.trim().toUpperCase(Locale.ROOT);
    if ("LIVE10".equals(c)) {
      discount = subtotal.multiply(new BigDecimal("0.10")).setScale(0, RoundingMode.HALF_UP);
      couponValid = true;
    } else if ("VIP20".equals(c)) {
      discount = subtotal.multiply(new BigDecimal("0.20")).setScale(0, RoundingMode.HALF_UP);
      couponValid = true;
    }
  }

  BigDecimal total = subtotal.subtract(discount);
  if (total.compareTo(BigDecimal.ZERO) < 0) total = BigDecimal.ZERO;

  NumberFormat COP = NumberFormat.getCurrencyInstance(new Locale("es","CO"));
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Checkout — <%= ev.getTitle() %></title>
  <style>
    /* Estética local similar a PagoSimulado */
    body{
      background: radial-gradient(circle at top, #171a33 0, #050712 45%, #02030a 100%);
    }

    .glassx{
      border:1px solid rgba(255,255,255,.10);
      background:rgba(255,255,255,.04);
      border-radius:16px;
      box-shadow:0 18px 60px rgba(0,0,0,.75);
    }

    .crumbs a{ opacity:.8 }
    .crumbs a:hover{ opacity:1; text-decoration:underline }

    .steps{
      display:grid;
      grid-template-columns:repeat(3,1fr);
      gap:8px;
    }
    .step{
      text-align:center;
      padding:10px 8px;
      border-radius:999px;
      border:1px solid rgba(255,255,255,.12);
      background:rgba(255,255,255,.05);
      font-weight:700;
      font-size:.85rem;
    }
    .step.is-active{
      border-color:rgba(0,209,178,.6);
      background:rgba(0,209,178,.12);
    }

    .badge{
      display:inline-block;
      padding:.25rem .6rem;
      border-radius:999px;
      border:1px solid rgba(255,255,255,.12);
      background:rgba(255,255,255,.06);
      font-weight:700;
      font-size:.85rem;
    }
    .muted{ color:rgba(255,255,255,.7) }
    .divider{
      height:1px;
      background:linear-gradient(90deg,transparent,rgba(255,255,255,.14),transparent);
      margin:12px 0;
    }

    .hidden{ display:none; }

    /* Cantidad */
    .qty-wrap{
      display:inline-flex;
      border:1px solid rgba(255,255,255,.15);
      border-radius:12px;
      overflow:hidden;
      background:rgba(0,0,0,.4);
    }
    .qty-btn{
      width:40px;
      height:40px;
      display:grid;
      place-items:center;
      cursor:pointer;
    }
    .qty-btn:hover{
      background:rgba(255,255,255,.06);
    }
    .qty-input{
      width:72px;
      text-align:center;
      background:transparent;
      border:0;
      color:#fff;
      font-weight:700;
      font-variant-numeric: tabular-nums;
    }

    /* Select tipo de ticket */
    .selectx{
      width:100%;
      padding:.6rem .8rem;
      border-radius:12px;
      background:rgba(0,0,0,.4);
      color:#fff;
      border:1px solid rgba(255,255,255,.15);
      outline:none;
    }
    .selectx:focus{
      border-color:rgba(0,209,178,.7);
    }

    /* Panel derecho */
    .sticky-box{ position:sticky; top:88px; }

    .pm-grid{
      display:grid;
      gap:8px;
      grid-template-columns:repeat(auto-fit,minmax(110px,1fr));
    }
    .pm{
      text-align:center;
      padding:10px;
      border:1px solid rgba(255,255,255,.10);
      border-radius:12px;
      background:rgba(255,255,255,.04);
      opacity:.9;
      font-size:.85rem;
    }

    .pm:hover{ opacity:1; }

    /* PQRS */
    .pqrs-grid{
      display:grid;
      gap:12px;
      grid-template-columns:1fr;
    }
    @media (min-width:768px){
      .pqrs-grid{ grid-template-columns:1fr 1fr; }
    }
    .input, .select, .textarea{
      width:100%;
      padding:.65rem .8rem;
      border-radius:12px;
      background:rgba(0,0,0,.4);
      color:#fff;
      border:1px solid rgba(255,255,255,.15);
      outline:none;
      font-size:.85rem;
    }
    .input:focus, .select:focus, .textarea:focus{
      border-color:rgba(0,209,178,.7);
    }

    /* FAQ */
    .faq-item{
      border:1px solid rgba(255,255,255,.1);
      border-radius:12px;
      overflow:hidden;
      background:rgba(255,255,255,.03);
    }
    .faq-q{
      width:100%;
      text-align:left;
      padding:12px 14px;
      font-weight:700;
      display:flex;
      align-items:center;
      justify-content:space-between;
      font-size:.88rem;
    }
    .faq-a{
      display:none;
      padding:0 14px 14px;
      color:rgba(255,255,255,.75);
      font-size:.85rem;
    }
    .faq-item.open .faq-a{ display:block; }

    /* Botón deshabilitado */
    .btn-disabled{
      opacity:.5;
      pointer-events:none;
    }
  </style>
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <main class="max-w-5xl mx-auto px-5 py-6">
    <!-- Breadcrumb + Pasos -->
    <div class="flex flex-col gap-3 mb-6">
      <nav class="crumbs text-sm">
        <a href="<%= request.getContextPath() %>/Vista/PaginaPrincipal.jsp" aria-label="Ir a la página de inicio">Inicio</a> /
        <a href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp" aria-label="Explorar eventos disponibles">Eventos</a> /
        <span class="opacity-100 font-semibold">Checkout</span>
      </nav>
      <div class="steps">
        <div class="step is-active">1) Resumen</div>
        <div class="step">2) Pago</div>
        <div class="step">3) Confirmación</div>
      </div>
    </div>

    <div class="grid md:grid-cols-3 gap-6">
      <!-- IZQ: detalle -->
      <section class="md:col-span-2 glassx p-6">
        <div class="flex items-start justify-between gap-3">
          <div>
            <h1 class="text-2xl font-extrabold mb-1"><%= ev.getTitle() %></h1>
            <p class="muted">📍 <%= ev.getVenue() %></p>
            <p class="muted">
              📅 <%= (ev.getDateTime()!=null
                ? ev.getDateTime().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))
                : ev.getDate()) %>
            </p>

            <!-- Tipo de ticket + aforo + disponibles -->
            <p class="muted mt-1">
              🎟️ Tipo de ticket actual: <b id="ticketTypeName"><%= ticketTypeName %></b>
              <% if (capacityTotal > 0) { %>
                &nbsp;• Aforo: <span id="ticketCapacity"><%= capacityTotal %></span>
              <% } else { %>
                &nbsp;• Aforo: <span id="ticketCapacity">-</span>
              <% } %>
            </p>
            <div class="mt-2">
              <span class="badge">Disponibles evento: <span id="availSpan"><%= avail %></span></span>
            </div>
          </div>
          <div class="text-right">
            <div class="badge">Evento</div>
          </div>
        </div>

        <div class="divider"></div>

        <!-- Selector de aforo + cantidad (TODO dinámico por JS) -->
        <div class="space-y-4">
          <!-- Tipo de ticket -->
          <div>
            <label class="block text-sm text-white/80 mb-1">Selecciona la localidad / tipo de ticket</label>
            <select id="ticketTypeSelect" class="selectx">
              <%
                // Cargamos todas las localidades del evento
                try {
                    Conexion cx2 = new Conexion();
                    String sql2 = "SELECT id, name, capacity, price FROM ticket_types WHERE id_event = ? ORDER BY price ASC";
                    try (Connection cn2 = cx2.getConnection();
                         PreparedStatement ps2 = cn2.prepareStatement(sql2)) {
                        ps2.setInt(1, eventId);
                        try (ResultSet rs2 = ps2.executeQuery()) {
                            boolean any = false;
                            while (rs2.next()) {
                                any = true;
                                int idTT     = rs2.getInt("id");
                                String name  = rs2.getString("name");
                                int capTT    = rs2.getInt("capacity");
                                BigDecimal p = rs2.getBigDecimal("price");
              %>
                <option
                    value="<%= idTT %>"
                    data-price="<%= (p!=null?p.toPlainString():"0") %>"
                    data-capacity="<%= capTT %>"
                    <%= (idTT == ticketTypeId ? "selected" : "") %>>
                  <%= name %> — <%= COP.format(p!=null?p:BigDecimal.ZERO) %>
                </option>
              <%
                            }
                            if (!any) {
              %>
                <option value="0" data-price="<%= unit.toPlainString() %>" data-capacity="0" selected>
                  Único precio disponible — <%= COP.format(unit) %>
                </option>
              <%
                            }
                        }
                    }
                    cx2.cerrarConexion();
                } catch (Exception e2) {
                    e2.printStackTrace();
              %>
                <option value="<%= ticketTypeId %>" data-price="<%= unit.toPlainString() %>" data-capacity="<%= capacityTotal %>" selected>
                  <%= ticketTypeName %> — <%= COP.format(unit) %>
                </option>
              <%
                }
              %>
            </select>
          </div>

          <!-- Cantidad -->
          <div class="flex flex-wrap items-center gap-3">
            <label class="text-white/80">Cantidad</label>
            <div class="qty-wrap">
              <button aria-label="Disminuir cantidad de entradas" class="qty-btn" type="button" id="btnMinus">−</button>
              <input class="qty-input" id="qtyInput" name="qty" type="number"
                     min="1" max="<%= Math.max(1, avail) %>" value="<%= qty %>"/>
              <button aria-label="Aumentar cantidad de entradas" class="qty-btn" type="button" id="btnPlus">+</button>
            </div>
            <span class="text-xs text-white/60">
              Máx. <span id="maxQtySpan"><%= Math.max(1, avail) %></span> entradas por compra.
            </span>
          </div>
        </div>

        <% if (avail == 0) { %>
          <div class="mt-3 p-3 rounded-lg bg-pink-600/20 border border-pink-400/40 text-sm">
            No hay disponibilidad para este evento en este momento.
          </div>
        <% } %>

        <div class="divider"></div>

        <!-- Confianza -->
        <div class="grid md:grid-cols-3 gap-3">
          <div class="glassx p-3 text-center text-sm">🔒 SSL / Datos seguros</div>
          <div class="glassx p-3 text-center text-sm">↩️ Reembolso sujeto a política del evento</div>
          <div class="glassx p-3 text-center text-sm">📧 Soporte 24/7</div>
        </div>

        <div class="divider"></div>

        <!-- FAQ -->
        <h2 class="font-bold text-lg mb-2">Preguntas frecuentes</h2>
        <div class="space-y-3">
          <div class="faq-item">
            <button aria-label="Mostrar información de cómo recibir las entradas"
                    class="faq-q">
              ¿Cómo recibo mis entradas?
              <svg width="16" height="16" viewBox="0 0 24 24"><path fill="currentColor" d="M7 10l5 5 5-5"/></svg>
            </button>
            <div class="faq-a">Tras el pago, te enviamos el QR al correo y lo verás en “Mis tickets”.</div>
          </div>
          <div class="faq-item">
            <button aria-label="Mostrar respuesta sobre entrar sin internet"
                    class="faq-q">
              ¿Puedo entrar sin internet?
              <svg width="16" height="16" viewBox="0 0 24 24"><path fill="currentColor" d="M7 10l5 5 5-5"/></svg>
            </button>
            <div class="faq-a">Sí. Descarga tu QR; los validadores funcionan offline.</div>
          </div>
          <div class="faq-item">
            <button aria-label="Mostrar información sobre transferencia de ticket"
                    class="faq-q">
              ¿Puedo transferir mi ticket?
              <svg width="16" height="16" viewBox="0 0 24 24"><path fill="currentColor" d="M7 10l5 5 5-5"/></svg>
            </button>
            <div class="faq-a">Según la política del organizador puedes transferirlo a otro usuario.</div>
          </div>
        </div>
      </section>

      <!-- DER: resumen pago -->
      <aside class="glassx p-6 h-fit sticky-box">
        <h3 class="font-bold text-lg mb-3">Resumen</h3>

        <!-- Cupón (aplicación sin recargar) -->
        <div class="mb-4">
          <div class="flex gap-2">
            <input type="text" id="couponInput" placeholder="Cupón (LIVE10 o VIP20)"
                   value="<%= (coupon!=null?coupon:"") %>"
                   class="w-full px-3 py-2 rounded-xl bg-transparent border border-white/15 focus:border-white/30 outline-none text-sm">
            <button aria-label="Aplicar descuento"
                    id="btnApplyCoupon"
                    class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30 text-sm">
              Aplicar
            </button>
          </div>
          <div id="couponMessage" class="mt-2 text-sm
              <%= coupon == null || coupon.isEmpty()
                  ? "text-white/60"
                  : (couponValid ? "text-green-300" : "text-pink-300") %>">
            <%
              if (coupon == null || coupon.isEmpty()) {
            %>
              Puedes usar LIVE10 (10%) o VIP20 (20%) si aplica.
            <%
              } else if (couponValid) {
            %>
              Cupón aplicado.
            <%
              } else {
            %>
              Cupón no válido.
            <%
              }
            %>
          </div>
        </div>

        <!-- Detalle precios (dinámico por JS) -->
        <ul class="text-white/80 space-y-1 text-sm">
          <li class="flex justify-between">
            <span>Precio unitario</span>
            <span id="unitPriceText"><%= COP.format(unit) %></span>
          </li>
          <li class="flex justify-between">
            <span>Cantidad</span>
            <span id="qtyText"><%= qty %></span>
          </li>
          <li class="flex justify-between">
            <span>Sub-total</span>
            <span id="subtotalText"><%= COP.format(subtotal) %></span>
          </li>
          <li id="discountRow" class="flex justify-between <%= discount.compareTo(BigDecimal.ZERO) > 0 ? "" : "hidden" %>">
            <span>Descuento</span>
            <span id="discountText">− <%= COP.format(discount) %></span>
          </li>
        </ul>
        <div class="divider"></div>
        <div class="flex justify-between items-center">
          <span class="font-bold">Total</span>
          <span id="totalText" class="font-extrabold text-xl"><%= COP.format(total) %></span>
        </div>

        <!-- Métodos de pago visuales -->
        <div class="pm-grid mt-4 text-xs">
          <div class="pm">💳 Visa</div>
          <div class="pm">💳 MasterCard</div>
          <div class="pm">🏦 PSE</div>
          <div class="pm">📱 Nequi</div>
        </div>

        <div class="mt-4 text-xs text-white/60">
          Al continuar aceptas los <a href="#" class="underline">Términos y condiciones</a> y la
          <a href="#" class="underline">Política de tratamiento de datos</a>.
        </div>

        <div class="mt-4">
          <label class="inline-flex items-center gap-2 text-sm">
            <input id="chkTerms" type="checkbox" class="accent-current">
            Acepto términos y políticas
          </label>
        </div>

        <div class="mt-4 space-y-3">
          <a id="btnPay"
             aria-label="Proceder al pago del pedido"
             class="btn-primary ripple block text-center btn-disabled
                    <%= (avail==0?" opacity-50 pointer-events-none":"") %>"
             href="<%= request.getContextPath() %>/Vista/PagoSimulado.jsp?eventId=<%= eventId %>&qty=<%= qty %>&coupon=<%= (coupon!=null?java.net.URLEncoder.encode(coupon, "UTF-8"):"") %>&ticketTypeId=<%= ticketTypeId %>">
            Pagar ahora (<span id="btnPayAmount"><%= COP.format(total) %></span>)
          </a>

          <a class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30 block text-center text-sm"
             href="<%= request.getContextPath() %>/Vista/EventoDetalle.jsp?id=<%= eventId %>">
            Ver detalles del evento
          </a>
          <a class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30 block text-center text-sm"
             href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp">
            Seguir explorando
          </a>
        </div>

        <!-- Datos ocultos para JS -->
        <input type="hidden" id="eventIdHidden" value="<%= eventId %>">
        <input type="hidden" id="initialTicketTypeId" value="<%= ticketTypeId %>">
      </aside>
    </div>

    <!-- PQRS COMPRAS -->
    <section class="mt-8 glassx p-6">
      <h3 class="text-xl font-extrabold">¿Necesitas ayuda con tu compra? (PQRS)</h3>
      <p class="text-white/70 mb-4 text-sm">
        Envíanos una <b>P</b>etición, <b>Q</b>ueja, <b>R</b>eclamo o <b>S</b>ugerencia sobre esta transacción.
      </p>
      <form action="<%= request.getContextPath() %>/Control/ct_pqrs_compra.jsp"
            method="post" enctype="multipart/form-data" class="space-y-3">
        <!-- Referencias ocultas -->
        <input type="hidden" name="eventId" value="<%= eventId %>">
        <input type="hidden" name="userId" value="<%= uid %>">
        <input type="hidden" id="pqrsMontoTotal" name="montoTotal" value="<%= COP.format(total) %>">
        <input type="hidden" name="eventoTitulo" value="<%= ev.getTitle().replace("\"","'") %>">

        <div class="pqrs-grid">
          <div>
            <label class="block text-sm mb-1">Tipo</label>
            <select class="select" name="tipo" required>
              <option value="">Selecciona…</option>
              <option>Petición</option>
              <option>Queja</option>
              <option>Reclamo</option>
              <option>Sugerencia</option>
            </select>
          </div>
          <div>
            <label class="block text-sm mb-1">Asunto</label>
            <input class="input" type="text" name="asunto"
                   placeholder="Ej. Error en el cobro / cambio de titular" required>
          </div>
          <div>
            <label class="block text-sm mb-1">Correo de contacto</label>
            <input class="input" type="email" name="email"
                   placeholder="tucorreo@ejemplo.com" required>
          </div>
          <div>
            <label class="block text-sm mb-1">Teléfono</label>
            <input class="input" type="tel" name="telefono" placeholder="+57 3xx xxx xxxx">
          </div>
          <div class="md:col-span-2">
            <label class="block text-sm mb-1">Detalle</label>
            <textarea class="textarea" name="detalle" rows="4"
                      placeholder="Cuéntanos qué ocurrió, número de referencia si lo tienes…" required></textarea>
          </div>
          <div class="md:col-span-2">
            <label class="block text-sm mb-1">Adjuntos (opcional)</label>
            <input class="input" type="file" name="adjunto" accept=".png,.jpg,.jpeg,.pdf">
            <p class="text-xs text-white/60 mt-1">
              Aceptamos imágenes o PDF (máx. 5 MB, configúralo en tu servlet si deseas limitar).
            </p>
          </div>
        </div>

        <div class="flex items-center justify-between gap-3">
          <label class="inline-flex items-center gap-2 text-sm">
            <input type="checkbox" required> Autorizo el tratamiento de mis datos para gestionar mi solicitud.
          </label>
          <button aria-label="Enviar formulario de PQRS" class="btn-primary text-sm px-4 py-2 rounded-xl">
            Enviar PQRS
          </button>
        </div>
      </form>
    </section>

    <!-- Franja de confianza -->
    <div class="grid sm:grid-cols-3 gap-4 mt-8 text-sm">
      <div class="glassx p-4 text-center">🔐 Pagos cifrados con TLS 1.2</div>
      <div class="glassx p-4 text-center">🧾 Factura electrónica disponible</div>
      <div class="glassx p-4 text-center">🛟 Soporte en vivo</div>
    </div>
  </main>

  <footer class="border-t border-white/10">
    <div class="max-w-5xl mx-auto px-5 py-6 flex flex-col sm:flex-row items-center justify-between text-white/70 text-sm">
      <div class="font-extrabold flex items-center gap-2">Livepass <span class="text-aqua">Buga</span></div>
      <div>© <%= java.time.Year.now() %> Livepass Buga</div>
    </div>
  </footer>

  <script>
    // Ripple
    (function(){
      document.querySelectorAll('.ripple').forEach(function(b){
        b.addEventListener('click', function(e){
          const r = this.getBoundingClientRect();
          const s = document.createElement('span');
          const z = Math.max(r.width, r.height);
          s.style.position = 'absolute';
          s.style.borderRadius = '50%';
          s.style.background = 'rgba(255,255,255,.3)';
          s.style.width  = z + 'px';
          s.style.height = z + 'px';
          s.style.left   = (e.clientX - r.left - z/2) + 'px';
          s.style.top    = (e.clientY - r.top  - z/2) + 'px';
          s.style.transform = 'scale(0)';
          s.style.opacity   = '1';
          s.style.pointerEvents = 'none';
          s.style.transition = 'transform .6s ease, opacity .6s ease';
          this.style.position = 'relative';
          this.appendChild(s);
          requestAnimationFrame(function(){
            s.style.transform = 'scale(2)';
            s.style.opacity   = '0';
          });
          setTimeout(function(){ s.remove(); }, 600);
        });
      });
    })();

    // FAQ
    (function(){
      document.querySelectorAll('.faq-item').forEach(function(it){
        const q = it.querySelector('.faq-q');
        q.addEventListener('click', function(){
          it.classList.toggle('open');
        });
      });
    })();

    // Cantidad con botones (sin recarga)
    (function(){
      var minus = document.getElementById('btnMinus'),
          plus  = document.getElementById('btnPlus'),
          input = document.getElementById('qtyInput');
      if (!minus || !plus || !input) return;

      function clamp(v){
        var min = parseInt(input.min || '1', 10),
            max = parseInt(input.max || '999', 10);
        v = isNaN(v) ? min : v;
        v = Math.max(min, Math.min(max, v));
        input.value = v;
        return v;
      }

      minus.addEventListener('click', function(){
        var v = clamp(parseInt(input.value || '1', 10) - 1);
        window._checkoutUpdate && window._checkoutUpdate();
      });
      plus.addEventListener('click', function(){
        var v = clamp(parseInt(input.value || '1', 10) + 1);
        window._checkoutUpdate && window._checkoutUpdate();
      });
      input.addEventListener('input', function(){
        clamp(parseInt(input.value || '1', 10));
        window._checkoutUpdate && window._checkoutUpdate();
      });
    })();

    // Lógica de precios / cupón / link de pago (todo dinámico)
    (function(){
      const formatter = new Intl.NumberFormat('es-CO', {style:'currency', currency:'COP'});

      const ticketSelect   = document.getElementById('ticketTypeSelect');
      const ticketTypeName = document.getElementById('ticketTypeName');
      const ticketCapacity = document.getElementById('ticketCapacity');
      const qtyInput       = document.getElementById('qtyInput');
      const qtyText        = document.getElementById('qtyText');
      const unitPriceText  = document.getElementById('unitPriceText');
      const subtotalText   = document.getElementById('subtotalText');
      const discountRow    = document.getElementById('discountRow');
      const discountText   = document.getElementById('discountText');
      const totalText      = document.getElementById('totalText');
      const btnPay         = document.getElementById('btnPay');
      const btnPayAmount   = document.getElementById('btnPayAmount');
      const chkTerms       = document.getElementById('chkTerms');
      const couponInput    = document.getElementById('couponInput');
      const couponMsg      = document.getElementById('couponMessage');
      const btnCoupon      = document.getElementById('btnApplyCoupon');
      const pqrsMontoTotal = document.getElementById('pqrsMontoTotal');
      const eventIdHidden  = document.getElementById('eventIdHidden');

      const avail          = parseInt((document.getElementById('availSpan')?.textContent || '0'), 10) || 0;
      const basePayUrl     = '<%= request.getContextPath() %>/Vista/PagoSimulado.jsp';

      if (!ticketSelect || !qtyInput) return;

      function getSelectedTicket(){
        const opt = ticketSelect.options[ticketSelect.selectedIndex];
        const id  = parseInt(opt.value || '0', 10) || 0;
        const pr  = parseFloat(opt.dataset.price || '0') || 0;
        const cap = parseInt(opt.dataset.capacity || '0', 10) || 0;
        const name= opt.textContent.split('—')[0].trim();
        return { id, price: pr, capacity: cap, name };
      }

      function getCouponDiscountPct(code){
        if (!code) return 0;
        const c = code.trim().toUpperCase();
        if (c === 'LIVE10') return 0.10;
        if (c === 'VIP20')  return 0.20;
        return 0;
      }

      function updateCouponMessage(pct, provided){
        if (!provided){
          couponMsg.className = 'mt-2 text-sm text-white/60';
          couponMsg.textContent = 'Puedes usar LIVE10 (10%) o VIP20 (20%) si aplica.';
          return;
        }
        if (pct > 0){
          couponMsg.className = 'mt-2 text-sm text-green-300';
          couponMsg.textContent = 'Cupón aplicado.';
        } else {
          couponMsg.className = 'mt-2 text-sm text-pink-300';
          couponMsg.textContent = 'Cupón no válido.';
        }
      }

      function updatePayHref(totalNumber){
        if (!btnPay) return;
        const eventId = parseInt(eventIdHidden.value || '0', 10) || 0;
        const qty  = parseInt(qtyInput.value || '1', 10) || 1;
        const sel  = getSelectedTicket();
        const cp   = couponInput.value.trim();
        const params = new URLSearchParams();
        params.set('eventId', String(eventId));
        params.set('qty', String(qty));
        params.set('ticketTypeId', String(sel.id));
        if (cp) params.set('coupon', cp);
        // amount lo recalcula PagoSimulado.jsp, no es obligatorio
        btnPay.href = basePayUrl + '?' + params.toString();
      }

      function updateTotals(){
        const sel = getSelectedTicket();
        let qty   = parseInt(qtyInput.value || '1', 10) || 1;
        // Clamp por disponibilidad
        if (avail > 0 && qty > avail){
          qty = avail;
          qtyInput.value = avail;
        } else if (qty < 1){
          qty = 1;
          qtyInput.value = 1;
        }

        const unit = sel.price;
        const subtotal = unit * qty;

        const cp  = couponInput.value.trim();
        const pct = getCouponDiscountPct(cp);
        const discount = subtotal * pct;
        const total    = Math.max(0, subtotal - discount);

        // Actualizar textos
        ticketTypeName.textContent = sel.name;
        ticketCapacity.textContent = sel.capacity > 0 ? sel.capacity : '-';

        qtyText.textContent       = qty;
        unitPriceText.textContent = formatter.format(unit);
        subtotalText.textContent  = formatter.format(subtotal);

        if (discount > 0){
          discountRow.classList.remove('hidden');
          discountText.textContent = '− ' + formatter.format(discount);
        } else {
          discountRow.classList.add('hidden');
          discountText.textContent = '';
        }
        totalText.textContent    = formatter.format(total);
        if (btnPayAmount) btnPayAmount.textContent = formatter.format(total);

        updateCouponMessage(pct, !!cp);
        if (pqrsMontoTotal) pqrsMontoTotal.value = formatter.format(total);

        updatePayHref(total);
        syncPayButton();
      }

      function syncPayButton(){
        if (!btnPay || !chkTerms) return;
        const canPay = chkTerms.checked && avail > 0;
        if (canPay){
          btnPay.classList.remove('btn-disabled','opacity-50','pointer-events-none');
        } else {
          btnPay.classList.add('btn-disabled','opacity-50','pointer-events-none');
        }
      }

      // Exponer para el módulo de cantidad
      window._checkoutUpdate = updateTotals;

      ticketSelect.addEventListener('change', updateTotals);
      chkTerms.addEventListener('change', syncPayButton);

      btnCoupon.addEventListener('click', function(e){
        e.preventDefault();
        updateTotals();
      });
      couponInput.addEventListener('keydown', function(e){
        if (e.key === 'Enter'){
          e.preventDefault();
          updateTotals();
        }
      });
      couponInput.addEventListener('blur', updateTotals);

      // Inicial
      updateTotals();
    })();
  </script>
</body>
</html>
