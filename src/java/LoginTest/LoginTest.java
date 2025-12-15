package LoginTest;

import org.junit.Test;
import org.junit.Before;
import static org.junit.Assert.*;
import java.sql.*;
import java.util.Optional;
import utils.User;
import dao.UserDAO;
import utils.PasswordUtil;

public class UserDAOTest {
    
    private Connection conexionTest;
    private UserDAO dao;
    
    @Before
    public void setUp() throws SQLException {
        System.out.println("🔄 Configurando entorno de prueba...");
        
        // Conectar a la base de datos de TEST
        conexionTest = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/livepass_test",  // Usar BD de test
            "root", "root"
        );
        
        // 1. Limpiar usuarios de prueba
        Statement stmt = conexionTest.createStatement();
        
        // Solo borrar usuarios con emails específicos de prueba
        stmt.execute("DELETE FROM usuarios WHERE email LIKE '%_test@%'");
        
        // 2. Insertar datos de prueba CON HASH REAL
        String hashLuis = PasswordUtil.hash("12345678");
        String hashOrg = PasswordUtil.hash("evento2024");
        
        // Usar emails CON "_test" para no interferir con datos reales
        stmt.execute("INSERT INTO usuarios (email, name, password_hash, role) VALUES " +
                     "('luis_test@gmail.com', 'Luis Test', '" + hashLuis + "', 'CLIENTE')," +
                     "('organizador_test@eventos.com', 'Eventos Test', '" + hashOrg + "', 'ORGANIZADOR')");
        
        stmt.close();
        conexionTest.close();
        
        // 3. Crear UserDAO (usará su conexión INTERNA)
        dao = new UserDAO();
    }
    
    @Test
    public void testAuthClienteExitoso() {
        System.out.println("\n🧪 TEST 1: auth() - Cliente válido");
        System.out.println("📝 Email: luis_test@gmail.com | Password: 12345678");
        
        Optional<User> result = dao.auth("luis_test@gmail.com", "12345678");
        
        assertTrue("❌ Debería encontrar usuario", result.isPresent());
        assertEquals("❌ Email no coincide", "luis_test@gmail.com", result.get().getEmail());
        assertEquals("❌ Rol incorrecto", "CLIENTE", result.get().getRole());
        
        System.out.println("✅ PASS - Cliente autenticado correctamente");
        System.out.println("   ID: " + result.get().getId());
        System.out.println("   Nombre: " + result.get().getName());
        System.out.println("   Rol: " + result.get().getRole());
    }
    
    @Test
    public void testAuthOrganizadorExitoso() {
        System.out.println("\n🧪 TEST 2: auth() - Organizador válido");
        System.out.println("📝 Email: organizador_test@eventos.com | Password: evento2024");
        
        Optional<User> result = dao.auth("organizador_test@eventos.com", "evento2024");
        
        assertTrue("❌ Debería encontrar organizador", result.isPresent());
        assertEquals("❌ Rol incorrecto", "ORGANIZADOR", result.get().getRole());
        
        System.out.println("✅ PASS - Organizador autenticado");
        System.out.println("   ID: " + result.get().getId());
        System.out.println("   Nombre: " + result.get().getName());
    }
    
    @Test
    public void testAuthPasswordIncorrecta() {
        System.out.println("\n🧪 TEST 3: auth() - Contraseña incorrecta");
        System.out.println("📝 Email: luis_test@gmail.com | Password: passwordErronea (INCORRECTA)");
        
        Optional<User> result = dao.auth("luis_test@gmail.com", "passwordErronea");
        
        assertFalse("❌ Contraseña incorrecta debería fallar", result.isPresent());
        System.out.println("✅ PASS - Contraseña incorrecta rechazada correctamente");
    }
    
    @Test
    public void testAuthUsuarioNoExistente() {
        System.out.println("\n🧪 TEST 4: auth() - Usuario no existente");
        System.out.println("📝 Email: noexiste@test.com | Password: cualquiera");
        
        Optional<User> result = dao.auth("noexiste_" + System.currentTimeMillis() + "@test.com", "cualquiera");
        
        assertFalse("❌ Usuario inexistente debería fallar", result.isPresent());
        System.out.println("✅ PASS - Usuario no existente rechazado");
    }
    
    // 🔧 MÉTODO MAIN para ejecutar todos los tests
    public static void main(String[] args) {
        System.out.println("🚀 INICIANDO PRUEBAS DE UserDAO");
        System.out.println("=".repeat(50));
        
        UserDAOTest testSuite = new UserDAOTest();
        
        try {
            testSuite.setUp();
            testSuite.testAuthClienteExitoso();
            
            testSuite.setUp();
            testSuite.testAuthOrganizadorExitoso();
            
            testSuite.setUp();
            testSuite.testAuthPasswordIncorrecta();
            
            testSuite.setUp();
            testSuite.testAuthUsuarioNoExistente();
            
            System.out.println("\n" + "=".repeat(50));
            System.out.println("🎉 TODAS LAS PRUEBAS DE UserDAO PASARON");
            System.out.println("=".repeat(50));
            
        } catch (Exception e) {
            System.err.println("\n❌ ERROR en pruebas: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}
