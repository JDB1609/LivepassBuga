<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.AdministradorDAO, utils.Administrador" %>
<%
  request.setCharacterEncoding("UTF-8");
  String email = request.getParameter("email");
  String pass  = request.getParameter("pass");

  if (email == null || pass == null) {
    request.setAttribute("login_error", "Completa tus credenciales.");
    request.getRequestDispatcher("../Vista/LoginAdmin.jsp").forward(request, response);
    return;
  }

  try {
    AdministradorDAO dao = new AdministradorDAO();
    java.util.Optional<utils.Administrador> opt = dao.auth(email.trim(), pass);

    if (opt.isEmpty()) {
      request.setAttribute("login_error", "Correo o contraseña incorrectos.");
      request.setAttribute("f_email", email);
      request.getRequestDispatcher("../Vista/LoginAdmin.jsp").forward(request, response);
      return;
    }

    utils.Administrador adm = opt.get();

    // Guardar información en la sesión
    session.setAttribute("adminId", adm.getId());
    session.setAttribute("adminNombre", adm.getName());
    session.setAttribute("adminEmail", adm.getEmail());

    // Definir rol explícito
    session.setAttribute("role", "ADMIN");

    // Redirigir directamente al backoffice
    String ctx = request.getContextPath();
    response.sendRedirect(ctx + "/Vista/BackofficeAdministrador.jsp");

  } catch (Exception ex) {
    request.setAttribute("login_error", "Error al iniciar sesión: " + ex.getMessage());
    request.setAttribute("f_email", email);
    request.getRequestDispatcher("../Vista/LoginAdmin.jsp").forward(request, response);
  }
%>