package utils;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Modelo Ticket para MisTickets.jsp y DAOs.
 * Incluye campos del ticket y columnas del evento traídas por JOIN.
 */
public class Ticket implements Serializable {

    // ---- ticket ----
    private int id;
    private int userId;
    private int eventId;
    private LocalDateTime purchaseAt; // timestamp de compra
    private String status;            // opcional: ACTIVO/USADO/REEMBOLSADO (si existe en tu BD)
    private String seat;              // opcional
    private String qrCode;            // opcional (texto para QR)

    // ---- datos del evento (JOIN) ----
    private String eventTitle;
    private String venue;
    private LocalDateTime eventDateTime;

    private static final DateTimeFormatter DMY = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    // ===== Getters usados en JSP =====
    public int getId() { return id; }
    public int getUserId() { return userId; }
    public int getEventId() { return eventId; }

    /** Título del evento (JOIN) */
    public String getEventTitle() { return eventTitle; }

    /** Lugar del evento (JOIN) */
    public String getVenue() { return venue; }

    /** Fecha del evento formateada dd/MM/yyyy para mostrar en JSP */
    public String getDate() {
        return eventDateTime != null ? eventDateTime.format(DMY) : "";
    }

    public LocalDateTime getEventDateTime() { return eventDateTime; }

    /** Estado del ticket (si lo manejas en BD) */
    public String getStatus() { return status; }

    /** Asiento (si aplicara) */
    public String getSeat() { return seat; }

    /** Texto/valor del QR (si lo manejas) */
    public String getQrCode() { return qrCode; }

    public LocalDateTime getPurchaseAt() { return purchaseAt; }

    // ===== Setters =====
    public void setId(int id) { this.id = id; }
    public void setUserId(int userId) { this.userId = userId; }
    public void setEventId(int eventId) { this.eventId = eventId; }
    public void setPurchaseAt(LocalDateTime purchaseAt) { this.purchaseAt = purchaseAt; }
    public void setStatus(String status) { this.status = status; }
    public void setSeat(String seat) { this.seat = seat; }
    public void setQrCode(String qrCode) { this.qrCode = qrCode; }

    public void setEventTitle(String eventTitle) { this.eventTitle = eventTitle; }
    public void setVenue(String venue) { this.venue = venue; }
    public void setEventDateTime(LocalDateTime eventDateTime) { this.eventDateTime = eventDateTime; }

    @Override
    public String toString() {
        return "Ticket{" +
                "id=" + id +
                ", userId=" + userId +
                ", eventId=" + eventId +
                ", purchaseAt=" + purchaseAt +
                ", status='" + status + '\'' +
                ", seat='" + seat + '\'' +
                ", qrCode='" + qrCode + '\'' +
                ", eventTitle='" + eventTitle + '\'' +
                ", venue='" + venue + '\'' +
                ", eventDateTime=" + eventDateTime +
                '}';
    }
}
