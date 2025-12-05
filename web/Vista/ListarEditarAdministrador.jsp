<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List, utils.Administrador, dao.AdministradorDAO" %>
<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"ADMIN".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/Vista/LoginAdmin.jsp");
        return;
    }

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
    <%@ include file="../Includes/head_base_administrador.jspf" %>
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

    input, select{
        background:transparent;
        border:1px solid rgba(255,255,255,0.08);
        padding:8px;
        color:#fff;
        border-radius:8px;
        width:100%;
    }

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

    /* ========================= */
    /* ✅ RESPONSIVO TABLAS */
    /* ========================= */
    @media (max-width: 768px) {
        .grid-form {
            grid-template-columns: 1fr;
        }

        table, thead, tbody, th, td, tr {
            display: block;
        }

        thead { display: none; }

        tr {
            margin-bottom: 14px;
            background: rgba(255,255,255,0.03);
            border-radius: 12px;
            padding: 12px;
        }

        td {
            border: 0;
            padding: 6px;
        }
    }

    /* ========================= */
    /* ✅ DISEÑO TARJETAS (NUEVO) */
    /* ========================= */
    .cards-grid{
        display:grid;
        grid-template-columns: repeat(auto-fill, minmax(280px,1fr));
        gap:18px;
    }

    .admin-card{
        background: rgba(255,255,255,0.04);
        border:1px solid rgba(255,255,255,0.08);
        border-radius:14px;
        padding:16px;
    }

    .edit-card{ display:none; }

    .info-card.hidden{ display:none; }
    .edit-card.show{ display:block; }

    .card-header{
        display:flex;
        justify-content:space-between;
        font-weight:800;
        margin-bottom:10px;
    }

    .badge{
        background:#00d1b2;
        color:#003;
        padding:4px 10px;
        border-radius:999px;
        font-size:.8rem;
    }

    .card-body p{
        margin:6px 0;
        font-size:.92rem;
    }

    .card-actions{
        display:flex;
        gap:10px;
        justify-content:flex-end;
        margin-top:14px;
    }
</style>
</head>
<body class="text-white">
    <%@ include file="../Includes/nav_base_administrador.jspf" %>

    <div class="container">

        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:14px; flex-wrap:wrap;">
            <div>
                <h1 style="margin:0">Administradores</h1>
                <div class="small">Lista y edición de administradores</div>
            </div>
            <a class="btn btn-edit" href="<%= request.getContextPath() %>/Vista/CrearAdministrador.jsp">Crear administrador</a>
        </div>

        <% String msg = request.getParameter("msg");
           if ("ok".equals(msg)) { %>
            <div class="msg ok">Cambios guardados correctamente.</div>
        <% } else if ("err".equals(msg)) { %>
            <div class="msg err">Ocurrió un error guardando.</div>
        <% } %>

        <div class="cards-grid">

        <% for (Administrador a : admins) { %>

            <!-- ✅ TARJETA INFO -->
            <div class="admin-card info-card" id="info-<%= a.getId() %>">
                <div class="card-header">
                    <strong><%= a.getName() %></strong>
                    <span class="badge"><%= a.getStatus() %></span>
                </div>

                <div class="card-body">
                    <p><b>ID:</b> <%= a.getId() %></p>
                    <p><b>Email:</b> <%= a.getEmail() %></p>
                    <p><b>Tel:</b> <%= a.getPhone() != null ? a.getPhone() : "-" %></p>
                    <p><b>Creado:</b> <%= a.getCreatedAt() %></p>
                </div>

                <div class="card-actions">
                    <button class="btn btn-edit" onclick="showEdit(<%= a.getId() %>)">Editar</button>
                </div>
            </div>

            <!-- ✅ TARJETA EDICIÓN -->
            <div class="admin-card edit-card" id="edit-<%= a.getId() %>">

                <form onsubmit="return validarPassword(<%= a.getId() %>)"
                      action="<%= request.getContextPath() %>/Control/ct_Listar_Editar_Administrador.jsp"
                      method="post">

                    <input type="hidden" name="id" value="<%= a.getId() %>">

                    <div class="grid-form">

                        <div class="form-group">
                            <label>Nombre</label>
                            <input name="name" value="<%= a.getName() %>">
                        </div>

                        <div class="form-group">
                            <label>Email</label>
                            <input type="email" name="email" value="<%= a.getEmail() %>">
                        </div>

                        <div class="form-group">
                            <label>Teléfono</label>
                            <input name="phone" value="<%= a.getPhone() %>">
                        </div>

                        <div class="form-group">
                            <label>Estado</label>
                            <select name="status">
                                <option value="ACTIVO">ACTIVO</option>
                                <option value="INACTIVO">INACTIVO</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Nueva contraseña</label>
                            <input type="password" id="pass1-<%= a.getId() %>" name="plainPass">
                        </div>

                        <div class="form-group">
                            <label>Confirmar contraseña</label>
                            <input type="password" id="pass2-<%= a.getId() %>">
                        </div>
                    </div>

                    <div class="card-actions">
                        <button type="button" class="btn btn-edit" onclick="hideEdit(<%= a.getId() %>)">Cancelar</button>
                        <button type="submit" class="btn btn-save">Guardar</button>
                    </div>

                </form>
            </div>

        <% } %>

        </div>
    </div>

<script>
    function showEdit(id){
        document.getElementById("info-"+id).classList.add("hidden");
        document.getElementById("edit-"+id).classList.add("show");
    }

    function hideEdit(id){
        document.getElementById("info-"+id).classList.remove("hidden");
        document.getElementById("edit-"+id).classList.remove("show");
    }

    // ✅ NUEVO: Validación doble de contraseña
    function validarPassword(id){
        let p1 = document.getElementById("pass1-"+id).value;
        let p2 = document.getElementById("pass2-"+id).value;

        if(p1 !== "" || p2 !== ""){
            if(p1 !== p2){
                alert("Las contraseñas no coinciden");
                return false;
            }
        }
        return true;
    }
</script>

</body>
</html>