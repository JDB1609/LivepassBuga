
package LoginTest;

import org.junit.Test;
import static org.junit.Assert.*;
import org.junit.Before;
import java.util.HashMap;
import java.util.Map;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;

// 🔧 SERVICIO REFACTORIZADO (lógica de negocio separada)
class LoginService {
    // Simulación de base de datos de usuarios
    private static final Map<String, String> USUARIOS_VALIDOS = new HashMap<>();
    
    static {
        // Datos de prueba - en un caso real vendrían de una base de datos
        USUARIOS_VALIDOS.put("luis@gmail.com", "12345678");
        USUARIOS_VALIDOS.put("organizador@eventos.com", "evento2024");
        USUARIOS_VALIDOS.put("admin@livepass.com", "admin123");
    }
    
    /**
     * Valida credenciales sin depender de HTTP
     * @return true si credenciales son válidas
     */
    public boolean validarCredenciales(String email, String password) {
        if (email == null || password == null || email.trim().isEmpty()) {
            return false;
        }
        
        String passGuardada = USUARIOS_VALIDOS.get(email.trim());
        return passGuardada != null && passGuardada.equals(password);
    }
    
    /**
     * Obtiene tipo de usuario (simulado)
     */
    public String obtenerTipoUsuario(String email) {
        if (email == null) return "invitado";
        
        if (email.contains("organizador")) return "organizador";
        if (email.contains("admin")) return "administrador";
        return "cliente";
    }
}

// 🔧 SIMULADOR DE RESPUESTA HTTP (para mantener compatibilidad)
class HttpSimulator {
    private LoginService loginService;
    
    public HttpSimulator(LoginService service) {
        this.loginService = service;
    }
    
    /**
     * Simula una petición POST al servidor
     * @return código de respuesta HTTP simulado
     */
    public int simularLoginHTTP(String email, String password) {
        System.out.println("🌐 Simulando petición HTTP para: " + email);
        
        if (loginService.validarCredenciales(email, password)) {
            System.out.println("✅ Login exitoso para: " + email);
            return 200; // OK
        } else {
            System.out.println("❌ Login fallido para: " + email);
            return 401; // Unauthorized
        }
    }
    
    /**
     * Simula respuesta completa con mensaje
     */
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

// 🧪 CLASE DE TEST ACTUAL (REFACTORIZADA)
public class LoginTest {
    
    private LoginService loginService;
    private HttpSimulator httpSimulator;
    private final ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
    private final PrintStream originalOut = System.out;
    
    @Before
    public void setUp() {
        loginService = new LoginService();
        httpSimulator = new HttpSimulator(loginService);
        System.setOut(new PrintStream(outputStream)); // Capturar salida
    }
    
    // ✅ TEST 1: LOGIN CORRECTO (cliente)
    @Test
    public void testLoginCorrectoCliente() {
        System.out.println("\n=== Test 1: Login correcto (cliente) ===");
        
        // Test directo del servicio
        boolean resultado = loginService.validarCredenciales("luis@gmail.com", "12345678");
        assertTrue("Credenciales válidas deberían retornar true", resultado);
        
        // Test simulación HTTP
        int codigoHTTP = httpSimulator.simularLoginHTTP("luis@gmail.com", "12345678");
        assertEquals(200, codigoHTTP);
        
        System.out.println("✅ Test 1 PASADO: Login cliente correcto");
    }
    
    // ✅ TEST 2: LOGIN CORRECTO (organizador)
    @Test
    public void testLoginCorrectoOrganizador() {
        System.out.println("\n=== Test 2: Login correcto (organizador) ===");
        
        boolean resultado = loginService.validarCredenciales("organizador@eventos.com", "evento2024");
        assertTrue(resultado);
        
        String respuesta = httpSimulator.simularLoginConMensaje("organizador@eventos.com", "evento2024");
        assertTrue(respuesta.contains("success"));
        assertTrue(respuesta.contains("organizador"));
        
        System.out.println("✅ Test 2 PASADO: Login organizador correcto");
    }
    
    // ❌ TEST 3: LOGIN CON CORREO INCORRECTO
    @Test
    public void testLoginCorreoIncorrecto() {
        System.out.println("\n=== Test 3: Login con correo incorrecto ===");
        
        boolean resultado = loginService.validarCredenciales("correo@invalido.com", "12345678");
        assertFalse("Credenciales inválidas deberían retornar false", resultado);
        
        String respuesta = httpSimulator.simularLoginConMensaje("correo@invalido.com", "12345678");
        assertTrue(respuesta.contains("error"));
        assertTrue(respuesta.contains("incorrectas"));
        
        System.out.println("✅ Test 3 PASADO: Correo incorrecto detectado");
    }
    
    // ❌ TEST 4: LOGIN CON CONTRASEÑA INCORRECTA
    @Test
    public void testLoginPasswordIncorrecta() {
        System.out.println("\n=== Test 4: Login con contraseña incorrecta ===");
        
        boolean resultado = loginService.validarCredenciales("luis@gmail.com", "mal123");
        assertFalse(resultado);
        
        int codigoHTTP = httpSimulator.simularLoginHTTP("luis@gmail.com", "mal123");
        assertEquals(401, codigoHTTP);
        
        System.out.println("✅ Test 4 PASADO: Contraseña incorrecta detectada");
    }
    
    // 🧪 TEST 5: USUARIO ADMIN
    @Test
    public void testLoginAdmin() {
        System.out.println("\n=== Test 5: Login administrador ===");
        
        boolean resultado = loginService.validarCredenciales("admin@livepass.com", "admin123");
        assertTrue(resultado);
        
        String respuesta = httpSimulator.simularLoginConMensaje("admin@livepass.com", "admin123");
        assertTrue(respuesta.contains("administrador"));
        
        System.out.println("✅ Test 5 PASADO: Login admin correcto");
    }
    
    // 🧪 TEST 6: CASOS BORDE
    @Test
    public void testCasosBorde() {
        System.out.println("\n=== Test 6: Casos borde ===");
        
        // Email vacío
        assertFalse(loginService.validarCredenciales("", "pass"));
        System.out.println("✓ Email vacío rechazado");
        
        // Email null
        assertFalse(loginService.validarCredenciales(null, "pass"));
        System.out.println("✓ Email null rechazado");
        
        // Password null
        assertFalse(loginService.validarCredenciales("luis@gmail.com", null));
        System.out.println("✓ Password null rechazado");
        
        // Email con espacios
        assertTrue(loginService.validarCredenciales("  luis@gmail.com  ", "12345678"));
        System.out.println("✓ Email con espacios aceptado (trim aplicado)");
        
        System.out.println("✅ Test 6 PASADO: Todos los casos borde");
    }
    
    // 🧪 TEST 7: VERIFICAR SALIDA EN CONSOLA
    @Test
    public void testSalidaConsola() {
        System.out.println("\n=== Test 7: Verificando salida en consola ===");
        
        // Ejecutar una operación que imprima
        httpSimulator.simularLoginHTTP("luis@gmail.com", "12345678");
        
        String output = outputStream.toString();
        assertTrue("Debe contener mensaje de simulación", output.contains("Simulando petición HTTP"));
        assertTrue("Debe contener mensaje de éxito", output.contains("Login exitoso"));
        
        System.out.println("✅ Test 7 PASADO: Salida en consola verificada");
        
        // Restaurar System.out
        System.setOut(originalOut);
        System.out.println(output); // Mostrar lo capturado
    }
    
    // 🔧 MÉTODO AUXILIAR: Mostrar resumen de todos los tests
    public static void main(String[] args) {
        System.out.println("🚀 INICIANDO SUITE DE TESTS REFACTORIZADA");
        System.out.println("==========================================");
        
        LoginTest testSuite = new LoginTest();
        
        try {
            testSuite.setUp();
            testSuite.testLoginCorrectoCliente();
            testSuite.testLoginCorrectoOrganizador();
            testSuite.testLoginCorreoIncorrecto();
            testSuite.testLoginPasswordIncorrecta();
            testSuite.testLoginAdmin();
            testSuite.testCasosBorde();
            testSuite.testSalidaConsola();
            
            System.out.println("\n🎉 TODOS LOS TESTS PASARON EXITOSAMENTE!");
            System.out.println("==========================================");
            System.out.println("Resumen:");
            System.out.println("- 7 tests unitarios independientes");
            System.out.println("- 0 dependencias externas (servidor/HTTP)");
            System.out.println("- 100% ejecutable en GitHub Actions");
            
        } catch (AssertionError e) {
            System.err.println("\n❌ ALGÚN TEST FALLÓ: " + e.getMessage());
            throw e;
        }
    }
}
