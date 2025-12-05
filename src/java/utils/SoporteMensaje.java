package utils;

import java.sql.Timestamp; // <--- import necesario

public class SoporteMensaje {

    private int id;
    private String nombre;
    private String email;
    private String mensaje;

    // ====== NUEVOS CAMPOS ======
    private String respuesta;   // puede ser null
    private Estado estado;      // enum: PENDIENTE, ATENDIDO
    private Timestamp fecha;    // <-- NUEVO CAMPO para el TIMESTAMP

    // ====== ENUM ESTADO ======
    public enum Estado {
        PENDIENTE,
        ATENDIDA
    }

    // ====== CONSTRUCTORES ======
    public SoporteMensaje() {
    }

    public SoporteMensaje(String nombre, String email, String mensaje) {
        this.nombre = nombre;
        this.email = email;
        this.mensaje = mensaje;
        this.respuesta = null;
        this.estado = null;
        this.fecha = null; // BD asignará timestamp por defecto
    }

    public SoporteMensaje(int id, String nombre, String email, String mensaje, String respuesta, Estado estado, Timestamp fecha) {
        this.id = id;
        this.nombre = nombre;
        this.email = email;
        this.mensaje = mensaje;
        this.respuesta = respuesta;
        this.estado = estado;
        this.fecha = fecha;
    }

    // ====== GETTERS ======
    public int getId() {
        return id;
    }

    public String getNombre() {
        return nombre;
    }

    public String getEmail() {
        return email;
    }

    public String getMensaje() {
        return mensaje;
    }

    public String getRespuesta() {
        return respuesta;
    }

    public Estado getEstado() {
        return estado;
    }

    public Timestamp getFecha() {  // <-- getter para la fecha
        return fecha;
    }

    // ====== SETTERS ======
    public void setId(int id) {
        this.id = id;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }

    public void setRespuesta(String respuesta) {
        this.respuesta = respuesta;
    }

    public void setEstado(Estado estado) {
        this.estado = estado;
    }

    public void setFecha(Timestamp fecha) {  // <-- setter para la fecha
        this.fecha = fecha;
    }

    @Override
    public String toString() {
        return "SoporteMensaje{" +
                "id=" + id +
                ", nombre='" + nombre + '\'' +
                ", email='" + email + '\'' +
                ", mensaje='" + mensaje + '\'' +
                ", respuesta='" + respuesta + '\'' +
                ", estado=" + estado +
                ", fecha=" + fecha +
                '}';
    }
}