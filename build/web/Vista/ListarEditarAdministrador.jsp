<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List, utils.Administrador, dao.AdministradorDAO" %>
<%
    // Verificación de sesión
    String role = (String) session.getAttribute("role");
    if (role == null || !"ADMIN".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/Vista/LoginAdmin.jsp");
        return;
    }

    // Declarar e inicializar la lista de administradores
    List<Administrador> admins = null;
    try {
        AdministradorDAO dao = new AdministradorDAO();
        admins = dao.listAll();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="../Includes/head_base.jspf" %>
    <title>Administradores — Livepass Buga</title>
    <style>
        body { background:#0b1020; color:#fff; font-family: inter, system-ui, sans-serif; }
        .container{ max-width:1100px; margin:36px auto; padding:20px; }
        .card{ background: rgba(255,255,255,0.03); border:1px solid rgba(255,255,255,0.06); border-radius:12px; padding:18px; }
        table{ width:100%; border-collapse:collapse; }
        th, td{ padding:10px 12px; text-align:left; color: #e8eef7; }
        th{ font-weight:800; color:#fff; border-bottom:1px solid rgba(255,255,255,0.06); }
        tr + tr td{ border-top:1px dashed rgba(255,255,255,0.03); }
        .btn{ padding:8px 12px; border-radius:10px; font-weight:800; cursor:pointer; }
        .btn-edit{ background:transparent; border:1px solid rgba(255,255,255,0.12); color:#fff; }
        .btn-save{ background:#00d1b2; color:#032; border:0; }
        .small{ font-size:.9rem; color:rgba(255,255,255,0.75); }
        input, select{ background:transparent; border:1px solid rgba(255,255,255,0.08); padding:8px; color:#fff; border-radius:8px; width:100%; }
        .edit-form { display: none !important; }
        .info-row { display: table-row; }
        .info-row.hidden { display: none !important; }
        .edit-form.show { display: table-row !important; }
        .grid-form {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 16px;
            margin: 16px 0;
        }
        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .form-group label {
            font-size: 0.9rem;
            color: rgba(255,255,255,0.8);
        }
        .msg{ padding:10px; border-radius:8px; margin-bottom:12px; }
        .ok{ background: rgba(0,209,178,0.12); color:#bfffe8; border:1px solid rgba(0,209,178,0.18); }
        .err{ background: rgba(255,80,80,0.08); color:#ffd7d7; border:1px solid rgba(255,80,80,0.12); }
    </style>
</head>
<body class="text-white">
    <%@ include file="../Includes/nav_base.jspf" %>

    <div class="container">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:14px">
            <div>
                <h1 style="margin:0">Administradores</h1>
                <div class="small">Lista y edición de administradores</div>
            </div>
            <div>
                <a class="btn btn-edit" href="<%= request.getContextPath() %>/Vista/CrearAdministrador.jsp">Crear administrador</a>
            </div>
        </div>

        <% String msg = request.getParameter("msg");
           if ("ok".equals(msg)) { %>
            <div class="msg ok">Cambios guardados correctamente.</div>
        <% } else if ("err".equals(msg)) { %>
            <div class="msg err">Ocurrió un error guardando. Revisa los datos e intenta de nuevo.</div>
        <% } %>

        <div class="card">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Nombre</th>
                        <th>Email</th>
                        <th>Teléfono</th>
                        <th>Estado</th>
                        <th>Creado</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (admins == null || admins.isEmpty()) { %>
                        <tr><td colspan="7" class="small">No hay administradores registrados.</td></tr>
                    <% } else {
                           for (Administrador a : admins) { %>
                        <tr class="info-row" id="info-<%= a.getId() %>">
                            <td><%= a.getId() %></td>
                            <td><%= a.getName() %></td>
                            <td><%= a.getEmail() %></td>
                            <td><%= a.getPhone() != null ? a.getPhone() : "-" %></td>
                            <td><%= a.getStatus() != null ? a.getStatus().name() : "ACTIVO" %></td>
                            <td><%= a.getCreatedAt() != null ? a.getCreatedAt().toString() : "-" %></td>
                            <td>
                                <button type="button" class="btn btn-edit" onclick="showEdit(<%= a.getId() %>)">Editar</button>
                            </td>
                        </tr>
                        <tr class="edit-form" id="edit-<%= a.getId() %>">
                            <td colspan="7">
                                <form action="<%= request.getContextPath() %>/Control/ct_Listar_Editar_Administrador.jsp" method="post">
                                    <input type="hidden" name="action" value="update">
                                    <input type="hidden" name="id" value="<%= a.getId() %>">
                                    
                                    <div class="grid-form">
                                        <div class="form-group">
                                            <label>Nombre:</label>
                                            <input name="name" value="<%= a.getName() %>" required />
                                        </div>
                                        <div class="form-group">
                                            <label>Email:</label>
                                            <input type="email" name="email" value="<%= a.getEmail() %>" required />
                                        </div>
                                        <div class="form-group">
                                            <label>Teléfono:</label>
                                            <input name="phone" value="<%= a.getPhone() != null ? a.getPhone() : "" %>" />
                                        </div>
                                        <div class="form-group">
                                            <label>Estado:</label>
                                            <select name="status">
                                                <option value="ACTIVO" <%= a.getStatus() == Administrador.Status.ACTIVO ? "selected" : "" %>>ACTIVO</option>
                                                <option value="INACTIVO" <%= a.getStatus() == Administrador.Status.INACTIVO ? "selected" : "" %>>INACTIVO</option>
                                            </select>
                                        </div>
                                        <div class="form-group">
                                            <label>Nueva contraseña (dejar vacío para mantener actual):</label>
                                            <input type="password" name="plainPass" />
                                        </div>
                                    </div>

                                    <div style="display:flex; gap:8px; justify-content:flex-end; margin-top:16px">
                                        <button type="button" class="btn btn-edit" onclick="hideEdit(<%= a.getId() %>)">Cancelar</button>
                                        <button type="submit" class="btn btn-save">Guardar cambios</button>
                                    </div>
                                </form>
                            </td>
                        </tr>
                    <% } } %>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        function showEdit(id) {
            console.log('Showing edit form for id:', id);
            const infoRow = document.getElementById('info-' + id);
            const editForm = document.getElementById('edit-' + id);
            
            if (infoRow && editForm) {
                infoRow.classList.add('hidden');
                editForm.classList.add('show');
            } else {
                console.error('Elements not found:', {infoRow, editForm});
            }
        }
        
        function hideEdit(id) {
            console.log('Hiding edit form for id:', id);
            const infoRow = document.getElementById('info-' + id);
            const editForm = document.getElementById('edit-' + id);
            
            if (infoRow && editForm) {
                infoRow.classList.remove('hidden');
                editForm.classList.remove('show');
            } else {
                console.error('Elements not found:', {infoRow, editForm});
            }
        }
    </script>
</body>
</html>