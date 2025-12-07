package utils;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Modelo Ticket para:
 * - MisTickets.jsp
 * - Pago / creación de tickets
 * - Validación de QR en la entrada
 *
 * Mapea columnas de:
 *   tickets        (id, user_id, event_id, qty, qty_qr_used, purchase_at,
 *                  payment_ref, qr_data, status, ticket_type_id)
 * + datos del evento (JOIN con events)
 * + datos del tipo de boleta (JOIN con ticket_types)
 */
public class Ticket implements Serializable {

    // ====== CAMPOS PRINCIPALES (tabla tickets) ======
    private int id;
    private int userId;          // user_id
    private int eventId;         // event_id

    private int qty;             // cantidad de boletas compradas
    private int qtyQrUsed;       // qty_qr_used

    private Integer ticketTypeId; // ticket_type_id (puede ser null)

    private LocalDateTime purchaseAt; // purchase_at
    private String paymentRef;        // payment_ref
    private String status;            // ACTIVO / USADO
    private String qrData;            // qr_data (payload LP|...)

    // ====== DATOS DEL EVENTO (JOIN events) ======
    private String eventTitle;
    private String venue;
    private String city;
    private LocalDateTime eventDateTime;

    // ====== DATOS DEL TIPO DE BOLETA (JOIN ticket_types) ======
    private String ticketTypeName;
    private Integer ticketTypeCapacity;
    private BigDecimal ticketTypePrice; // MIN/price de ese tipo

    private static final DateTimeFormatter DMY =
            DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter DMY_HM =
            DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    // ========== GETTERS BÁSICOS USADOS EN JSP ==========

    public int getId() { return id; }
    public int getUserId() { return userId; }
    public int getEventId() { return eventId; }

    public int getQty() { return qty; }
    public int getQtyQrUsed() { return qtyQrUsed; }

    public Integer getTicketTypeId() { return ticketTypeId; }

    public LocalDateTime getPurchaseAt() { return purchaseAt; }
    public String getPurchaseAtFormatted() {
        return purchaseAt != null ? purchaseAt.format(DMY_HM) : "";
    }

    public String getPaymentRef() { return paymentRef; }
    public String getStatus() { return status; }

    /** Texto completo guardado en tickets.qr_data */
    public String getQrData() { return qrData; }

    /** Alias de compatibilidad si en algún JSP usas getQrCode() */
    public String getQrCode() { return qrData; }

    // ===== EVENTO =====
    public String getEventTitle() { return eventTitle; }
    public String getVenue() { return venue; }
    public String getCity() { return city; }

    /** Fecha del evento tipo dd/MM/yyyy (para listado) */
    public String getDate() {
        return eventDateTime != null ? eventDateTime.format(DMY) : "";
    }

    public LocalDateTime getEventDateTime() { return eventDateTime; }

    // ===== TIPO DE BOLETA =====
    public String getTicketTypeName() { return ticketTypeName; }
    public Integer getTicketTypeCapacity() { return ticketTypeCapacity; }
    public BigDecimal getTicketTypePrice() { return ticketTypePrice; }

    // ========== SETTERS ==========

    public void setId(int id) { this.id = id; }
    public void setUserId(int userId) { this.userId = userId; }
    public void setEventId(int eventId) { this.eventId = eventId; }

    public void setQty(int qty) { this.qty = qty; }
    public void setQtyQrUsed(int qtyQrUsed) { this.qtyQrUsed = qtyQrUsed; }

    public void setTicketTypeId(Integer ticketTypeId) {
        this.ticketTypeId = ticketTypeId;
    }

    public void setPurchaseAt(LocalDateTime purchaseAt) {
        this.purchaseAt = purchaseAt;
    }

    public void setPaymentRef(String paymentRef) {
        this.paymentRef = paymentRef;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public void setQrData(String qrData) {
        this.qrData = qrData;
    }

    /** Alias por si en algún lado usas setQrCode(...) */
    public void setQrCode(String qrCode) {
        this.qrData = qrCode;
    }

    // ---- Evento ----
    public void setEventTitle(String eventTitle) {
        this.eventTitle = eventTitle;
    }

    public void setVenue(String venue) {
        this.venue = venue;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public void setEventDateTime(LocalDateTime eventDateTime) {
        this.eventDateTime = eventDateTime;
    }

    // ---- Tipo de boleta ----
    public void setTicketTypeName(String ticketTypeName) {
        this.ticketTypeName = ticketTypeName;
    }

    public void setTicketTypeCapacity(Integer ticketTypeCapacity) {
        this.ticketTypeCapacity = ticketTypeCapacity;
    }

    public void setTicketTypePrice(BigDecimal ticketTypePrice) {
        this.ticketTypePrice = ticketTypePrice;
    }

    @Override
    public String toString() {
        return "Ticket{" +
                "id=" + id +
                ", userId=" + userId +
                ", eventId=" + eventId +
                ", qty=" + qty +
                ", qtyQrUsed=" + qtyQrUsed +
                ", ticketTypeId=" + ticketTypeId +
                ", purchaseAt=" + purchaseAt +
                ", paymentRef='" + paymentRef + '\'' +
                ", status='" + status + '\'' +
                ", qrData='" + qrData + '\'' +
                ", eventTitle='" + eventTitle + '\'' +
                ", venue='" + venue + '\'' +
                ", city='" + city + '\'' +
                ", eventDateTime=" + eventDateTime +
                ", ticketTypeName='" + ticketTypeName + '\'' +
                ", ticketTypeCapacity=" + ticketTypeCapacity +
                ", ticketTypePrice=" + ticketTypePrice +
                '}';
    }
}
