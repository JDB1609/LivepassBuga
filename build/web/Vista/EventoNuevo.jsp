<%@ page contentType="text/html; charset=UTF-8" %>
<%
  Integer uid = (Integer) session.getAttribute("userId");
  String role = (String) session.getAttribute("role");
  if (uid == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }
  if (role == null || !"ORGANIZADOR".equalsIgnoreCase(role)) {
    response.sendRedirect(request.getContextPath()+"/Vista/HomeCliente.jsp"); return;
  }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Nuevo evento</title>
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <main class="max-w-3xl mx-auto px-5 py-10">
    <h1 class="text-2xl font-extrabold mb-4">Crear evento</h1>

    <form action="<%= request.getContextPath() %>/Control/ct_event_create.jsp" method="post"
          class="glass ring rounded-2xl p-6 grid gap-4">

      <div>
        <label class="block mb-2 text-white/80">Título</label>
        <input name="title" required class="w-full px-4 py-2 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary"/>
      </div>

      <div class="grid sm:grid-cols-2 gap-4">
        <div>
          <label class="block mb-2 text-white/80">Lugar (venue)</label>
          <input name="venue" required class="w-full px-4 py-2 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary"/>
        </div>
        <div>
          <label class="block mb-2 text-white/80">Ciudad</label>
          <input name="city" required class="w-full px-4 py-2 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary"/>
        </div>
      </div>

      <div class="grid sm:grid-cols-2 gap-4">
        <div>
          <label class="block mb-2 text-white/80">Género</label>
          <input name="genre" placeholder="Pop, Rock, Teatro..." class="w-full px-4 py-2 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary"/>
        </div>
        <div>
          <label class="block mb-2 text-white/80">Fecha y hora</label>
          <input type="datetime-local" name="date_time" required class="w-full px-4 py-2 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary"/>
        </div>
      </div>

      <div class="grid sm:grid-cols-3 gap-4">
        <div>
          <label class="block mb-2 text-white/80">Capacidad</label>
          <input type="number" name="capacity" min="1" value="100" required
                 class="w-full px-4 py-2 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary"/>
        </div>
        <div>
          <label class="block mb-2 text-white/80">Precio (COP)</label>
          <input name="price" placeholder="20000" required
                 class="w-full px-4 py-2 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary"/>
        </div>
        <div>
          <label class="block mb-2 text-white/80">Estado</label>
          <select name="status" class="ui-select sm w-full">
            <option value="BORRADOR">Borrador</option>
            <option value="PENDIENTE">A revisión</option>
          </select>
        </div>
      </div>


      
      <div>
        <label class="block mb-2 text-white/80">Descripción</label>
        <textarea 
          name="description"
          maxlength="500"
          rows="3"
          placeholder="Describe el evento..."
          class="w-full px-4 py-2 rounded-xl bg-white/5 ring resize-none overflow-auto
                 focus:outline-none focus:ring-2 focus:ring-primary"
        ></textarea>
        <p class="text-sm text-white/50 mt-1">Máximo 500 caracteres</p>
      </div>

      <!-- IMAGEN (URL) -->
      <div>
        <label class="block mb-2 text-white/80">URL de la imagen</label>
        <input 
          name="image"
          placeholder="https://ejemplo.com/imagen.jpg"
          class="w-full px-4 py-2 rounded-xl bg-white/5 ring
                 focus:outline-none focus:ring-2 focus:ring-primary"
        />
      </div>
      
      <div class="mt-4 flex gap-3">
        <button class="btn-primary ripple" type="submit">Crear</button>
        <a class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30"
           href="<%= request.getContextPath() %>/Vista/EventosOrganizador.jsp">Cancelar</a>
      </div>
    </form>
  </main>
</body>
</html>
