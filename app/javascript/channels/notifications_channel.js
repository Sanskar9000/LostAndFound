import consumer from "channels/consumer"

let subscribed = false

const updateNotificationCount = (count) => {
  document.querySelectorAll("[data-notification-count]").forEach((element) => {
    element.textContent = count
    element.classList.toggle("d-none", count === 0)
  })
}

const ensureToastContainer = () => {
  let container = document.getElementById("notificationToastContainer")
  if (container) return container

  container = document.createElement("div")
  container.id = "notificationToastContainer"
  container.className = "notification-toast-container position-fixed top-0 end-0 p-3"
  document.body.appendChild(container)
  return container
}

const showToast = (data) => {
  const container = ensureToastContainer()
  const toast = document.createElement("div")
  toast.className = "toast show notification-toast border-0 mb-2"
  toast.role = "alert"
  toast.innerHTML = `
    <div class="toast-header">
      <strong class="me-auto">${data.title}</strong>
      <button type="button" class="btn-close ms-2 mb-1" data-bs-dismiss="toast" aria-label="Close"></button>
    </div>
    <div class="toast-body">
      <div>${data.body}</div>
      ${data.link_path ? `<a href="${data.link_path}" class="small text-decoration-none">Open</a>` : ""}
    </div>
  `

  container.prepend(toast)
  setTimeout(() => toast.remove(), 6000)
}

const prependNotification = (html) => {
  const list = document.getElementById("notificationsList")
  if (!list || !html) return
  list.insertAdjacentHTML("afterbegin", html)
}

const subscribeToNotifications = () => {
  if (subscribed) return
  if (!document.body || document.body.dataset.authenticated !== "true") return

  subscribed = true

  consumer.subscriptions.create("NotificationsChannel", {
    received(data) {
      updateNotificationCount(data.unread_count || 0)
      prependNotification(data.item_html)
      showToast(data)
    }
  })
}

document.addEventListener("turbo:load", subscribeToNotifications)
document.addEventListener("DOMContentLoaded", subscribeToNotifications)
