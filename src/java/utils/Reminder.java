
package utils;

import java.sql.Timestamp;

public class Reminder {
    private int id;
    private String userEmail;
    private String message;
    private Timestamp shippingDate;
    private boolean sent;

    public Reminder() {
    }

    public Reminder(int id, String userEmail, String message, Timestamp shippingDate, boolean sent) {
        this.id = id;
        this.userEmail = userEmail;
        this.message = message;
        this.shippingDate = shippingDate;
        this.sent = sent;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Timestamp getShippingDate() {
        return shippingDate;
    }

    public void setShippingDate(Timestamp shippingDate) {
        this.shippingDate = shippingDate;
    }

    public boolean isSent() {
        return sent;
    }

    public void setSent(boolean sent) {
        this.sent = sent;
    }

    @Override
    public String toString() {
        return "Reminder{" + "id=" + id + ", userEmail=" + userEmail + ", message=" + message + ", shippingDate=" + shippingDate + ", sent=" + sent + '}';
    }
}
