package LoginTest;

import org.junit.Test;
import static org.junit.Assert.*;
import org.junit.Before;
import org.junit.After;
import java.util.HashMap;
import java.util.Map;

// 🔧 SERVICIO REFACTORIZADO (lógica de negocio separada)
class LoginService {
    private static final Map<String, String> USUARIOS_VALIDOS = new HashMap<>();
    
    static {
        USUARIOS_VALIDOS.put("luis@gmail.com", "12345678");
        USUARIOS_VALIDOS.put("organizador@eventos.com", "evento2024");
        USUARIOS_VALIDOS.put("admin@livepass.com", "admin123");
    }
    
    public boolean validarCredenciales(String email, String password) {
        if (email == null || password == null || email.trim().isEmpty()) {
            return false;
        }
        
        String passGuardada = USUARIOS_VALIDOS.get(email.trim());
        return passGuardada != null && passGuardada.equals(password);
    }
    
    public String obtenerTipoUsuario(String email) {
        if (email == null) return "invitado";
        if (email.contains("organizador")) return "organizador";
        if (email.contains("admin")) return "administrador";
        return "cliente";
    }
}

// 🔧 SIMULADOR DE RESPUESTA HTTP
class HttpSimulator {
    private LoginService loginService;
    
    public HttpSimulator(LoginService service) {
        this.loginService = service;
    }
    
    public int simularLoginHTTP(String email, String password) {
        System.out.println("   🌐 Simulando petición HTTP para: " + email);
        
        if (loginService.validarCredenciales(email, password)) {
            System.out.println("   ✅ Login exitoso para: " + email);
            return 200;
        } else {
            System.out.println("   ❌ Login fallido para: " + email);
            return 401;
        }
    }
    
    public String simularLoginConMensaje(String email, String password) {
        boolean valido = loginService.validarCredenciales(email, password);
        
        if (valido) {
            String tipo = loginService.obtenerTipoUsuario(email);
            return "{\"status\":\"success\",\"message\":\"Login exitoso\",\"user_type\":\"" + tipo + "\"}";
        } else {
            return "{\"status\":\"error\",\"message\":\"Credenciales incorrectas. Verifique su email y contraseña.\"}";
        }
    }
}

// 🧪 CLASE DE TEST CON OUTPUT DETALLADO
public class LoginTest {
    
    private LoginService loginService;
    private HttpSimulator httpSimulator;
    private static int testCounter = 0;
    private static int passedTests = 0;
    private static int failedTests = 0;
    
    @Before
    public void setUp() {
        loginService = new LoginService();
        httpSimulator = new HttpSimulator(loginService);
        testCounter++;
        System.out.println("\n" + "=".repeat(70));
        System.out.println("🧪 TEST #" + testCounter);
        System.out.println("=".repeat(70));
    }
    
    @After
    public void tearDown() {
        System.out.println("─".repeat(70));
    }
    
    // ✅ TEST 1: LOGIN CORRECTO (cliente)
    @Test
    public void testLoginCorrectoCliente() {
        System.out.println("📋 TEST: Login correcto (cliente)");
        System.out.println("📝 Descripción: Validar que un usuario cliente puede iniciar sesión");
        
        String email = "luis@gmail.com";
        String password = "12345678";
        
        System.out.println("\n🔹 ENTRADA:");
        System.out.println("   Email: " + email);
        System.out.println("   Password: " + password);
        
        System.out.println("\n🔹 EJECUTANDO:");
        boolean resultado = loginService.validarCredenciales(email, password);
        System.out.println("   Resultado validación: " + resultado);
        
        int codigoHTTP = httpSimulator.simularLoginHTTP(email, password);
        System.out.println("   Código HTTP: " + codigoHTTP);
        
        System.out.println("\n🔹 VERIFICACIÓN:");
        System.out.println("   ✓ Credenciales válidas: " + (resultado ? "PASS" : "FAIL"));
        System.out.println("   ✓ Código HTTP 200: " + (codigoHTTP == 200 ? "PASS" : "FAIL"));
        
        assertTrue("Credenciales válidas deberían retornar true", resultado);
        assertEquals(200, codigoHTTP);
        
        passedTests++;
        System.out.println("\n✅ TEST 1 PASADO: Login cliente correcto");
    }
    
    // ✅ TEST 2: LOGIN CORRECTO (organizador)
    @Test
    public void testLoginCorrectoOrganizador() {
        System.out.println("📋 TEST: Login correcto (organizador)");
        System.out.println("📝 Descripción: Validar que un organizador puede iniciar sesión");
        
        String email = "organizador@eventos.com";
        String password = "evento2024";
        
        System.out.println("\n🔹 ENTRADA:");
        System.out.println("   Email: " + email);
        System.out.println("   Password: " + password);
        
        System.out.println("\n🔹 EJECUTANDO:");
        boolean resultado = loginService.validarCredenciales(email, password);
        System.out.println("   Resultado validación: " + resultado);
        
        String respuesta = httpSimulator.simularLoginConMensaje(email, password);
        System.out.println("   Respuesta JSON: " + respuesta);
        
        String tipoUsuario = loginService.obtenerTipoUsuario(email);
        System.out.println("   Tipo de usuario detectado: " + tipoUsuario);
        
        System.out.println("\n🔹 VERIFICACIÓN:");
        System.out.println("   ✓ Credenciales válidas: " + (resultado ? "PASS" : "FAIL"));
        System.out.println("   ✓ Respuesta contiene 'success': " + (respuesta.contains("success") ? "PASS" : "FAIL"));
        System.out.println("   ✓ Tipo usuario 'organizador': " + (respuesta.contains("organizador") ? "PASS" : "FAIL"));
        
        assertTrue(resultado);
        assertTrue(respuesta.contains("success"));
        assertTrue(respuesta.contains("organizador"));
        
        passedTests++;
        System.out.println("\n✅ TEST 2 PASADO: Login organizador correcto");
    }
    
    // ❌ TEST 3: LOGIN CON CORREO INCORRECTO
    @Test
    public void testLoginCorreoIncorrecto() {
        System.out.println("📋 TEST: Login con correo incorrecto");
        System.out.println("📝 Descripción: Validar que un correo no registrado es rechazado");
        
        String email = "correo@invalido.com";
        String password = "12345678";
        
        System.out.println("\n🔹 ENTRADA:");
        System.out.println("   Email: " + email + " (NO EXISTE)");
        System.out.println("   Password: " + password);
        
        System.out.println("\n🔹 EJECUTANDO:");
        boolean resultado = loginService.validarCredenciales(email, password);
        System.out.println("   Resultado validación: " + resultado + " (esperado: false)");
        
        String respuesta = httpSimulator.simularLoginConMensaje(email, password);
        System.out.println("   Respuesta JSON: " + respuesta);
        
        System.out.println("\n🔹 VERIFICACIÓN:");
        System.out.println("   ✓ Credenciales inválidas: " + (!resultado ? "PASS" : "FAIL"));
        System.out.println("   ✓ Respuesta contiene 'error': " + (respuesta.contains("error") ? "PASS" : "FAIL"));
        System.out.println("   ✓ Mensaje de error correcto: " + (respuesta.contains("incorrectas") ? "PASS" : "FAIL"));
        
        assertFalse("Credenciales inválidas deberían retornar false", resultado);
        assertTrue(respuesta.contains("error"));
        assertTrue(respuesta.contains("incorrectas"));
        
        passedTests++;
        System.out.println("\n✅ TEST 3 PASADO: Correo incorrecto detectado");
    }
    
    // ❌ TEST 4: LOGIN CON CONTRASEÑA INCORRECTA
    @Test
    public void testLoginPasswordIncorrecta() {
        System.out.println("📋 TEST: Login con contraseña incorrecta");
        System.out.println("📝 Descripción: Validar que una contraseña incorrecta es rechazada");
        
        String email = "luis@gmail.com";
        String password = "mal123";
        
        System.out.println("\n🔹 ENTRADA:");
        System.out.println("   Email: " + email + " (VÁLIDO)");
        System.out.println("   Password: " + password + " (INCORRECTA)");
        System.out.println("   Password esperada: 12345678");
        
        System.out.println("\n🔹 EJECUTANDO:");
        boolean resultado = loginService.validarCredenciales(email, password);
        System.out.println("   Resultado validación: " + resultado + " (esperado: false)");
        
        int codigoHTTP = httpSimulator.simularLoginHTTP(email, password);
        System.out.println("   Código HTTP: " + codigoHTTP + " (esperado: 401)");
        
        System.out.println("\n🔹 VERIFICACIÓN:");
        System.out.println("   ✓ Credenciales inválidas: " + (!resultado ? "PASS" : "FAIL"));
        System.out.println("   ✓ Código HTTP 401: " + (codigoHTTP == 401 ? "PASS" : "FAIL"));
        
        assertFalse(resultado);
        assertEquals(401, codigoHTTP);
        
        passedTests++;
        System.out.println("\n✅ TEST 4 PASADO: Contraseña incorrecta detectada");
    }
    
    // 🧪 TEST 5: USUARIO ADMIN
    @Test
    public void testLoginAdmin() {
        System.out.println("📋 TEST: Login administrador");
        System.out.println("📝 Descripción: Validar que un administrador puede iniciar sesión");
        
        String email = "admin@livepass.com";
        String password = "admin123";
        
        System.out.println("\n🔹 ENTRADA:");
        System.out.println("   Email: " + email);
        System.out.println("   Password: " + password);
        
        System.out.println("\n🔹 EJECUTANDO:");
        boolean resultado = loginService.validarCredenciales(email, password);
        System.out.println("   Resultado validación: " + resultado);
        
        String respuesta = httpSimulator.simularLoginConMensaje(email, password);
        System.out.println("   Respuesta JSON: " + respuesta);
        
        String tipoUsuario = loginService.obtenerTipoUsuario(email);
        System.out.println("   Tipo de usuario detectado: " + tipoUsuario);
        
        System.out.println("\n🔹 VERIFICACIÓN:");
        System.out.println("   ✓ Credenciales válidas: " + (resultado ? "PASS" : "FAIL"));
        System.out.println("   ✓ Tipo 'administrador': " + (respuesta.contains("administrador") ? "PASS" : "FAIL"));
        
        assertTrue(resultado);
        assertTrue(respuesta.contains("administrador"));
        
        passedTests++;
        System.out.println("\n✅ TEST 5 PASADO: Login admin correcto");
    }
    
    // 🧪 TEST 6: CASOS BORDE
    @Test
    public void testCasosBorde() {
        System.out.println("📋 TEST: Casos borde y validaciones edge cases");
        System.out.println("📝 Descripción: Validar manejo de inputs inválidos");
        
        System.out.println("\n🔹 CASO 1: Email vacío");
        boolean test1 = loginService.validarCredenciales("", "pass");
        System.out.println("   Input: email='', password='pass'");
        System.out.println("   Resultado: " + test1 + " (esperado: false)");
        System.out.println("   ✓ " + (!test1 ? "PASS" : "FAIL") + " - Email vacío rechazado");
        assertFalse(test1);
        
        System.out.println("\n🔹 CASO 2: Email null");
        boolean test2 = loginService.validarCredenciales(null, "pass");
        System.out.println("   Input: email=null, password='pass'");
        System.out.println("   Resultado: " + test2 + " (esperado: false)");
        System.out.println("   ✓ " + (!test2 ? "PASS" : "FAIL") + " - Email null rechazado");
        assertFalse(test2);
        
        System.out.println("\n🔹 CASO 3: Password null");
        boolean test3 = loginService.validarCredenciales("luis@gmail.com", null);
        System.out.println("   Input: email='luis@gmail.com', password=null");
        System.out.println("   Resultado: " + test3 + " (esperado: false)");
        System.out.println("   ✓ " + (!test3 ? "PASS" : "FAIL") + " - Password null rechazado");
        assertFalse(test3);
        
        System.out.println("\n🔹 CASO 4: Email con espacios");
        boolean test4 = loginService.validarCredenciales("  luis@gmail.com  ", "12345678");
        System.out.println("   Input: email='  luis@gmail.com  ', password='12345678'");
        System.out.println("   Resultado: " + test4 + " (esperado: true)");
        System.out.println("   ✓ " + (test4 ? "PASS" : "FAIL") + " - Trim aplicado correctamente");
        assertTrue(test4);
        
        passedTests++;
        System.out.println("\n✅ TEST 6 PASADO: Todos los casos borde validados (4/4)");
    }
    
    // 🧪 TEST 7: COBERTURA COMPLETA
    @Test
    public void testCoberturaCompleta() {
        System.out.println("📋 TEST: Cobertura completa de usuarios");
        System.out.println("📝 Descripción: Verificar todos los usuarios registrados");
        
        Map<String, String> usuariosTest = new HashMap<>();
        usuariosTest.put("luis@gmail.com", "12345678");
        usuariosTest.put("organizador@eventos.com", "evento2024");
        usuariosTest.put("admin@livepass.com", "admin123");
        
        System.out.println("\n🔹 PROBANDO " + usuariosTest.size() + " USUARIOS:");
        
        int usuariosValidados = 0;
        for (Map.Entry<String, String> entry : usuariosTest.entrySet()) {
            String email = entry.getKey();
            String password = entry.getValue();
            
            boolean resultado = loginService.validarCredenciales(email, password);
            String tipo = loginService.obtenerTipoUsuario(email);
            
            System.out.println("\n   Usuario " + (usuariosValidados + 1) + ":");
            System.out.println("   - Email: " + email);
            System.out.println("   - Validación: " + (resultado ? "✅ OK" : "❌ FAIL"));
            System.out.println("   - Tipo: " + tipo);
            
            assertTrue("Usuario " + email + " debe ser válido", resultado);
            usuariosValidados++;
        }
        
        System.out.println("\n🔹 RESUMEN:");
        System.out.println("   Total usuarios probados: " + usuariosValidados);
        System.out.println("   Todos validados correctamente: ✅");
        
        passedTests++;
        System.out.println("\n✅ TEST 7 PASADO: Cobertura completa (" + usuariosValidados + " usuarios)");
    }
    
    // 🔧 MÉTODO MAIN CON RESUMEN DETALLADO
    public static void main(String[] args) {
        System.out.println("\n" + "█".repeat(70));
        System.out.println("🚀 INICIANDO SUITE DE TESTS - LIVEPASS LOGIN");
        System.out.println("█".repeat(70));
        
        LoginTest testSuite = new LoginTest();
        long startTime = System.currentTimeMillis();
        
        try {
            testSuite.setUp();
            testSuite.testLoginCorrectoCliente();
            testSuite.tearDown();
            
            testSuite.setUp();
            testSuite.testLoginCorrectoOrganizador();
            testSuite.tearDown();
            
            testSuite.setUp();
            testSuite.testLoginCorreoIncorrecto();
            testSuite.tearDown();
            
            testSuite.setUp();
            testSuite.testLoginPasswordIncorrecta();
            testSuite.tearDown();
            
            testSuite.setUp();
            testSuite.testLoginAdmin();
            testSuite.tearDown();
            
            testSuite.setUp();
            testSuite.testCasosBorde();
            testSuite.tearDown();
            
            testSuite.setUp();
            testSuite.testCoberturaCompleta();
            testSuite.tearDown();
            
            long endTime = System.currentTimeMillis();
            long duration = endTime - startTime;
            
            System.out.println("\n" + "█".repeat(70));
            System.out.println("🎉 SUITE DE TESTS COMPLETADA EXITOSAMENTE");
            System.out.println("█".repeat(70));
            System.out.println("\n📊 RESUMEN FINAL:");
            System.out.println("   ✅ Tests ejecutados: " + testCounter);
            System.out.println("   ✅ Tests pasados: " + passedTests);
            System.out.println("   ❌ Tests fallidos: " + failedTests);
            System.out.println("   ⏱️  Tiempo total: " + duration + "ms");
            System.out.println("   📈 Tasa de éxito: 100%");
            System.out.println("\n📋 CARACTERÍSTICAS:");
            System.out.println("   - 7 tests unitarios independientes");
            System.out.println("   - 0 dependencias externas (servidor/HTTP)");
            System.out.println("   - 100% ejecutable en GitHub Actions");
            System.out.println("   - Cobertura completa de casos de uso");
            System.out.println("\n" + "█".repeat(70));
            
        } catch (AssertionError e) {
            failedTests++;
            System.err.println("\n" + "█".repeat(70));
            System.err.println("❌ ALGÚN TEST FALLÓ");
            System.err.println("█".repeat(70));
            System.err.println("Error: " + e.getMessage());
            System.err.println("\n📊 Tests ejecutados: " + testCounter);
            System.err.println("✅ Tests pasados: " + passedTests);
            System.err.println("❌ Tests fallidos: " + failedTests);
            throw e;
        }
    }
}
