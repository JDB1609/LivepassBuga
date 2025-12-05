<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.EventDAO, utils.Event" %>
<%@ page import="java.math.BigDecimal, java.math.RoundingMode, java.text.NumberFormat, java.util.Locale" %>

<%
  // --- Guard de sesión ---
  Integer uid = (Integer) session.getAttribute("userId");
  if (uid == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }

  // --- Parámetros ---
  int eventId = 0, qty = 1;
  String coupon = request.getParameter("coupon");
  try { eventId = Integer.parseInt(request.getParameter("eventId")); } catch(Exception ignore){}
  try { qty = Math.max(1, Integer.parseInt(request.getParameter("qty"))); } catch(Exception ignore){}
  if (eventId <= 0) { response.sendRedirect(request.getContextPath()+"/Vista/PaginaPrincipal.jsp"); return; }

  // --- Cargar evento ---
  Event ev = new EventDAO().findById(eventId).orElse(null);
  if (ev == null) { response.sendRedirect(request.getContextPath()+"/Vista/PaginaPrincipal.jsp"); return; }

  // Disponibilidad
  int avail = Math.max(0, ev.getAvailability());
  if (avail > 0 && qty > avail) qty = avail;

  // Precio unitario y cálculos
  BigDecimal unit = (ev.getPriceValue()!=null) ? ev.getPriceValue() : BigDecimal.ZERO;
  BigDecimal subtotal = unit.multiply(BigDecimal.valueOf(qty));

  // Fees (demo)
  BigDecimal serviceFee = subtotal.multiply(new BigDecimal("0.05")).setScale(0, RoundingMode.HALF_UP);
  BigDecimal processing  = new BigDecimal("2000");

  // Cupón demo
  BigDecimal discount = BigDecimal.ZERO;
  boolean couponValid = false;
  if (coupon != null && !coupon.trim().isEmpty()) {
    String c = coupon.trim().toUpperCase(Locale.ROOT);
    if ("LIVE10".equals(c)) { discount = subtotal.multiply(new BigDecimal("0.10")).setScale(0, RoundingMode.HALF_UP); couponValid = true; }
    else if ("VIP20".equals(c)) { discount = subtotal.multiply(new BigDecimal("0.20")).setScale(0, RoundingMode.HALF_UP); couponValid = true; }
  }

  BigDecimal total = subtotal.add(serviceFee).add(processing).subtract(discount);
  if (total.compareTo(BigDecimal.ZERO) < 0) total = BigDecimal.ZERO;

  NumberFormat COP = NumberFormat.getCurrencyInstance(new Locale("es","CO"));
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Checkout — <%= ev.getTitle() %></title>
  <style>
    /* Estética local */
    .glassx{ border:1px solid rgba(255,255,255,.10); background:rgba(255,255,255,.04); border-radius:16px }
    .crumbs a{ opacity:.8 } .crumbs a:hover{ opacity:1; text-decoration:underline }
    .steps{ display:grid; grid-template-columns:repeat(3,1fr); gap:8px }
    .step{ text-align:center; padding:10px 8px; border-radius:999px; border:1px solid rgba(255,255,255,.12); background:rgba(255,255,255,.05); font-weight:700; }
    .step.is-active{ border-color:rgba(0,209,178,.6); background:rgba(0,209,178,.12) }

    .badge{ display:inline-block; padding:.25rem .6rem; border-radius:999px; border:1px solid rgba(255,255,255,.12); background:rgba(255,255,255,.06); font-weight:700; font-size:.85rem }
    .muted{ color:rgba(255,255,255,.7) }
    .divider{ height:1px; background:linear-gradient(90deg,transparent,rgba(255,255,255,.14),transparent); margin:12px 0 }

    /* Cantidad */
    .qty-wrap{ display:inline-flex; border:1px solid rgba(255,255,255,.15); border-radius:12px; overflow:hidden }
    .qty-btn{ width:40px; height:40px; display:grid; place-items:center; }
    .qty-input{ width:72px; text-align:center; background:transparent; border:0; color:#fff; font-weight:700 }

    /* Panel derecho */
    .sticky-box{ position:sticky; top:88px }
    .pm-grid{ display:grid; gap:8px; grid-template-columns:repeat(auto-fit,minmax(110px,1fr)); }
    .pm{ text-align:center; padding:10px; border:1px solid rgba(255,255,255,.10); border-radius:12px; background:rgba(255,255,255,.04); opacity:.9 }
    .pm:hover{ opacity:1 }

    /* FAQ */
    .faq-item{ border:1px solid rgba(255,255,255,.1); border-radius:12px; overflow:hidden; background:rgba(255,255,255,.03) }
    .faq-q{ width:100%; text-align:left; padding:12px 14px; font-weight:700 }
    .faq-a{ display:none; padding:0 14px 14px; color:rgba(255,255,255,.75) }
    .faq-item.open .faq-a{ display:block }

    /* PQRS */
    .pqrs-grid{ display:grid; gap:12px; grid-template-columns:1fr; }
    @media (min-width:768px){ .pqrs-grid{ grid-template-columns:1fr 1fr; } }
    .input, .select, .textarea{
      width:100%; padding:.65rem .8rem; border-radius:12px;
      background:transparent; color:#fff; border:1px solid rgba(255,255,255,.15);
      outline: none;
    }
    .input:focus, .select:focus, .textarea:focus{ border-color:rgba(255,255,255,.30) }
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
            <p class="muted">📅 <%= (ev.getDateTime()!=null
                ? ev.getDateTime().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"))
                : ev.getDate()) %></p>
            <div class="mt-2"><span class="badge">Disponibles: <%= avail %></span></div>
          </div>
          <div class="text-right"><div class="badge">Evento</div></div>
        </div>

        <div class="divider"></div>

        <!-- Cantidad -->
        <form action="<%= request.getContextPath() %>/Vista/Checkout.jsp" method="get" class="flex flex-wrap items-center gap-3">
          <input type="hidden" name="eventId" value="<%= eventId %>"/>
          <label class="text-white/80">Cantidad</label>
          <div class="qty-wrap">
            <button id= "btnMinus" aria-label="Disminuir cantidad de entradas" class="qty-btn" type="button" id="btnMinus">−</button>
            <input class="qty-input" id="qtyInput" name="qty" type="number" min="1" max="<%= Math.max(1, avail) %>" value="<%= qty %>"/>
            <button id= "btnPlus" aria-label="Aumentar cantidad de entradas" class="qty-btn" type="button" id="btnPlus">+</button>
          </div>
          <button class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30" type="submit" aria-label="Actualizar información del pedido">Actualizar</button>
        </form>

        <% if (avail == 0) { %>
          <div class="mt-3 p-3 rounded-lg bg-pink-600/20 border border-pink-400/40">
            No hay disponibilidad para este evento en este momento.
          </div>
        <% } %>

        <div class="divider"></div>

        <!-- Confianza -->
        <div class="grid md:grid-cols-3 gap-3">
          <div class="glassx p-3 text-center">🔒 SSL / Datos seguros</div>
          <div class="glassx p-3 text-center">↩️ Reembolso sujeto a política del evento</div>
          <div class="glassx p-3 text-center">📧 Soporte 24/7</div>
        </div>

        <div class="divider"></div>

        <!-- FAQ -->
        <h2 class="font-bold text-lg mb-2">Preguntas frecuentes</h2>
        <div class="space-y-3">
          <div class="faq-item">
            <button arial-label="Mostrar información de cómo recibir las entradas" class="faq-q flex items-center justify-between w-full"
              >¿Cómo recibo mis entradas?<svg width="16" height="16" viewBox="0 0 24 24"><path fill="currentColor" d="M7 10l5 5 5-5"/></svg>
            </button>
            <div class="faq-a">Tras el pago, te enviamos el QR al correo y lo verás en “Mis tickets”.</div>
          </div>
          <div class="faq-item">
            <button arial-label="Mostrar respuesta sobre entrar sin internet" class="faq-q flex items-center justify-between w-full">
                ¿Puedo entrar sin internet?<svg width="16" height="16" viewBox="0 0 24 24"><path fill="currentColor" d="M7 10l5 5 5-5"/></svg>
            </button>
            <div class="faq-a">Sí. Descarga tu QR; los validadores funcionan offline.</div>
          </div>
          <div class="faq-item">
            <button arial-label="Mostrar información sobre transferencia de ticket" class="faq-q flex items-center justify-between w-full">
                ¿Puedo transferir mi ticket?<svg width="16" height="16" viewBox="0 0 24 24"><path fill="currentColor" d="M7 10l5 5 5-5"/></svg>
            </button>
            <div class="faq-a">Según la política del organizador puedes transferirlo a otro usuario.</div>
          </div>
        </div>
      </section>

      <!-- DER: resumen pago -->
      <aside class="glassx p-6 h-fit sticky-box">
        <h3 class="font-bold text-lg mb-3">Resumen</h3>

        <!-- Cupón -->
        <form action="<%= request.getContextPath() %>/Vista/Checkout.jsp" method="get" class="mb-4">
          <input type="hidden" name="eventId" value="<%= eventId %>"/>
          <input type="hidden" name="qty" value="<%= qty %>"/>
          <div class="flex gap-2">
            <input type="text" name="coupon" placeholder="Cupón (LIVE10 o VIP20)" value="<%= (coupon!=null?coupon:"") %>"
                   class="w-full px-3 py-2 rounded-xl bg-transparent border border-white/15 focus:border-white/30 outline-none">
            <button 
                arial-label="Aplicar descuento" class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30" type="submit">Aplicar
            </button>
          </div>
          <% if (coupon != null && !coupon.isEmpty()) { %>
            <div class="mt-2 text-sm <%= couponValid ? "text-green-300" : "text-pink-300" %>">
              <%= couponValid ? "Cupón aplicado" : "Cupón no válido" %>
            </div>
          <% } %>
        </form>

        <!-- Detalle -->
        <ul class="text-white/80 space-y-1 text-sm">
          <li class="flex justify-between"><span>Precio unitario</span><span><%= COP.format(unit) %></span></li>
          <li class="flex justify-between"><span>Cantidad</span><span><%= qty %></span></li>
          <li class="flex justify-between"><span>Sub-total</span><span><%= COP.format(subtotal) %></span></li>
          <li class="flex justify-between"><span>Fee servicio (5%)</span><span><%= COP.format(serviceFee) %></span></li>
          <li class="flex justify-between"><span>Procesamiento</span><span><%= COP.format(processing) %></span></li>
          <% if (discount.compareTo(BigDecimal.ZERO) > 0) { %>
            <li class="flex justify-between text-green-300"><span>Descuento</span><span>− <%= COP.format(discount) %></span></li>
          <% } %>
        </ul>
        <div class="divider"></div>
        <div class="flex justify-between items-center">
          <span class="font-bold">Total</span>
          <span class="font-extrabold text-xl"><%= COP.format(total) %></span>
        </div>

        <!-- Métodos de pago -->
        <div class="pm-grid mt-4">
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
          <a id="btnPay" arial-label="Proceder al pago del pedido" class="btn-primary ripple block text-center <%= (avail==0?"opacity-50 pointer-events-none":"") %>"
             href="<%= request.getContextPath() %>/Vista/PagoSimulado.jsp?eventId=<%= eventId %>&qty=<%= qty %>&coupon=<%= (coupon!=null?coupon:"") %>">
            Pagar ahora (<%= COP.format(total) %>)
          </a>
          <a class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30 block text-center"
             href="<%= request.getContextPath() %>/Vista/EventoDetalle.jsp?id=<%= eventId %>">Ver detalles del evento</a>
          <a class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30 block text-center"
             href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp">Seguir explorando</a>
        </div>
      </aside>
    </div>

    <!-- PQRS COMPRAS -->
    <section class="mt-8 glassx p-6">
      <h3 class="text-xl font-extrabold">¿Necesitas ayuda con tu compra? (PQRS)</h3>
      <p class="text-white/70 mb-4">Envíanos una <b>P</b>etición, <b>Q</b>ueja, <b>R</b>eclamo o <b>S</b>ugerencia sobre esta transacción.</p>
      <form action="<%= request.getContextPath() %>/Control/ct_pqrs_compra.jsp" method="post" enctype="multipart/form-data" class="space-y-3">
        <!-- Referencias ocultas -->
        <input type="hidden" name="eventId" value="<%= eventId %>">
        <input type="hidden" name="userId" value="<%= uid %>">
        <input type="hidden" name="montoTotal" value="<%= COP.format(total) %>">
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
            <input class="input" type="text" name="asunto" placeholder="Ej. Error en el cobro / cambio de titular" required>
          </div>
          <div>
            <label class="block text-sm mb-1">Correo de contacto</label>
            <input class="input" type="email" name="email" placeholder="tucorreo@ejemplo.com" required>
          </div>
          <div>
            <label class="block text-sm mb-1">Teléfono</label>
            <input class="input" type="tel" name="telefono" placeholder="+57 3xx xxx xxxx">
          </div>
          <div class="md:col-span-2">
            <label class="block text-sm mb-1">Detalle</label>
            <textarea class="textarea" name="detalle" rows="4" placeholder="Cuéntanos qué ocurrió, número de referencia si lo tienes…" required></textarea>
          </div>
          <div class="md:col-span-2">
            <label class="block text-sm mb-1">Adjuntos (opcional)</label>
            <input class="input" type="file" name="adjunto" accept=".png,.jpg,.jpeg,.pdf">
            <p class="text-xs text-white/60 mt-1">Aceptamos imágenes o PDF (máx. 5 MB, configúralo en tu servlet si deseas limitar).</p>
          </div>
        </div>

        <div class="flex items-center justify-between gap-3">
          <label class="inline-flex items-center gap-2 text-sm">
            <input type="checkbox" required> Autorizo el tratamiento de mis datos para gestionar mi solicitud.
          </label>
          <button arial-label="Enviar formulario de PQRS" class="btn-primary">Enviar PQRS</button>
        </div>
      </form>
    </section>

    <!-- Franja de confianza -->
    <div class="grid sm:grid-cols-3 gap-4 mt-8">
      <div class="glassx p-4 text-center">🔐 Pagos cifrados con TLS 1.2</div>
      <div class="glassx p-4 text-center">🧾 Factura electrónica disponible</div>
      <div class="glassx p-4 text-center">🛟 Soporte en vivo</div>
    </div>
  </main>

  <footer class="border-t border-white/10">
    <div class="max-w-5xl mx-auto px-5 py-6 flex flex-col sm:flex-row items-center justify-between text-white/70">
      <div class="font-extrabold flex items-center gap-2">Livepass <span class="text-aqua">Buga</span></div>
      <div>© <%= java.time.Year.now() %> Livepass Buga</div>
    </div>
  </footer>

  <script>
    // Ripple
    (function(){ document.querySelectorAll('.ripple').forEach(b=>b.addEventListener('click',function(e){
      const r=this.getBoundingClientRect(),s=document.createElement('span'),z=Math.max(r.width,r.height);
      s.style.width=s.style.height=z+'px'; s.style.left=(e.clientX-r.left-z/2)+'px'; s.style.top=(e.clientY-r.top-z/2)+'px';
      this.appendChild(s); setTimeout(()=>s.remove(),600);
    }));})();

    // FAQ
    (function(){
      document.querySelectorAll('.faq-item').forEach(it=>{
        it.querySelector('.faq-q').addEventListener('click', ()=> it.classList.toggle('open'));
      });
    })();

    // Cantidad con botones
    (function(){
      var minus=document.getElementById('btnMinus'), plus=document.getElementById('btnPlus'), input=document.getElementById('qtyInput');
      if(!minus||!plus||!input) return;
      function clamp(v){
        var min=parseInt(input.min||'1',10), max=parseInt(input.max||'999',10);
        v=isNaN(v)?min:v; v=Math.max(min, Math.min(max, v)); input.value=v;
      }
      minus.addEventListener('click', ()=>clamp(parseInt(input.value||'1',10)-1));
      plus .addEventListener('click', ()=>clamp(parseInt(input.value||'1',10)+1));
    })();

    // Pagar sólo si acepta términos
    (function(){
      var chk=document.getElementById('chkTerms'), pay=document.getElementById('btnPay');
      if(!chk||!pay) return;
      function sync(){ if(chk.checked){ pay.classList.remove('opacity-50','pointer-events-none'); } else { pay.classList.add('opacity-50','pointer-events-none'); } }
      chk.addEventListener('change', sync); sync();
    })();
  </script>
</body>
</html>
