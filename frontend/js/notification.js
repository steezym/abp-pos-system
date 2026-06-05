let lastNotificationId = 0;
let currentNotifications = [];
class NotificationManager {

    renderComponent() {

        const container =
            document.getElementById(
                'notification-container'
            );

        if (!container) return;

        container.innerHTML = `
            <div class="notification-wrapper">

                <button
                    class="btn-icon"
                    id="btnNotification">

                    <i class="bi bi-bell"></i>

                    <span
                        id="notifBadge"
                        class="badge bg-danger rounded-pill"
                        style="
                            position:absolute;
                            top:-5px;
                            right:-5px;
                            font-size:10px;
                        ">
                        0
                    </span>

                </button>

                <div
                    id="notifDropdown"
                    class="card shadow"
                    style="
                        display:none;
                        position:absolute;
                        right:0;
                        top:40px;
                        width:320px;
                        z-index:9999;
                    ">

                    <div class="card-header fw-bold">
                        Notifications
                    </div>

                    <div
                        id="notifList"
                        style="
                            max-height:300px;
                            overflow:auto;
                        ">
                    </div>

                </div>

            </div>
        `;
    }

    async load() {
        console.log("NOTIF LOAD");
        try {

            const result =
    await api.get('/notifications');

const notifications =
    result.notifications || [];

currentNotifications =
    notifications;

if (
    notifications.length > 0
)
{
    lastNotificationId =
        Math.max(
            lastNotificationId,
            notifications[0].id
        );
}

this.render(notifications);

            const badge =
                document.getElementById(
                    'notifBadge'
                );

            if (badge) {
                const seenId =
    Number(
        localStorage.getItem(
            'notif_seen_id'
        ) || 0
    );
console.log("SEEN ID =", seenId);

console.log(
    "NOTIFICATIONS =",
    result.notifications.map(
        x => x.id
    )
);

console.log(
    "UNREAD =",
    result.notifications
        .filter(x => x.id > seenId)
        .map(x => x.id)
);
const unread =
    result.notifications.filter(
        x => x.id > seenId
    );

if (unread.length > 0)
{
    badge.style.display =
        'inline-block';

    badge.textContent =
        unread.length;
}
else
{
    badge.style.display =
        'none';
}
            }

        } catch(error){

            console.error(error);

        }
    }

    render(data) {

        const container =
            document.getElementById(
                'notifList'
            );

        if (!container) return;

        if (data.length === 0) {

            container.innerHTML = `
                <div class="p-3 text-center text-muted">
                    Tidak ada notifikasi
                </div>
            `;

            return;
        }

        container.innerHTML =
data.map(item => `

<div class="p-3 border-bottom">

    <div class="fw-semibold">
        ${item.title}
    </div>

    <small class="text-muted d-block">
        ${item.message}
    </small>

    <div class="mt-2">
    <small class="text-muted">
        ${new Date(item.created_at).toLocaleString(
    'id-ID',
    {
        day: '2-digit',
        month: 'short',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    }
)}
    </small>
</div>

</div>

`).join('');
    }

    showRealtimeAlert(notif)
{
    // transaksi tidak popup
    if (
        notif.type ===
        'transaction'
    )
    {
        return;
    }

    let icon = 'warning';

    if (
        notif.type ===
        'out_of_stock'
    )
    {
        icon = 'error';
    }

    Swal.fire({

        icon: icon,

        title:
            notif.title,

        text:
            notif.message,

        confirmButtonText:
            'OK',

        allowOutsideClick:
            false

    });
}

    init() {
        console.log("NOTIF INIT");
        this.renderComponent();

        const btn =
            document.getElementById(
                'btnNotification'
            );

        const dropdown =
            document.getElementById(
                'notifDropdown'
            );

        btn.addEventListener(
    'click',
    () => {

        dropdown.style.display =
            dropdown.style.display === 'block'
            ? 'none'
            : 'block';

        const badge =
            document.getElementById(
                'notifBadge'
            );

        if (
            currentNotifications.length > 0
        ) {

            const latestId =
    currentNotifications[0].id;

console.log(
    "SAVE ID =",
    latestId
);

localStorage.setItem(
    'notif_seen_id',
    latestId
);
        }

        if (badge) {

            badge.textContent = '';

            badge.style.display =
                'none';
        }

    }
);

        this.load();
    }
}

const notificationManager =
    new NotificationManager();

async function markNotifRead(id)
{
    try {

        await api.post(
            `/notifications/read/${id}`
        );

        notificationManager.load();

    }
    catch(error)
    {
        console.error(error);
    }
}

function restockProduct(id)
{
    window.location.href =
        `edit-product.html?id=${id}`;
}

setInterval(async () => {

    try {

        const result =
            await api.get(
                '/notifications'
            );

        const notifications =
            result.notifications || [];

        if (
            notifications.length > 0
        ) {

            const latest =
                notifications[0];

            if (
    latest.id >
    lastNotificationId
) {

    lastNotificationId =
        latest.id;

    if (
        latest.type === 'low_stock' ||
        latest.type === 'out_of_stock'
    ) {

        notificationManager
            .showRealtimeAlert(
                latest
            );
    }

    notificationManager.load();
}
        }

    } catch(error) {

        console.error(error);

    }

}, 5000);