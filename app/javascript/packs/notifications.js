function fetchNotificationsCount() {
  const notificationBadge = document.getElementById("notificationBadge");
  fetch("/notifications/count")
    .then((response) => response.json())
    .then((data) => {
      notificationBadge.innerText = data.unread_count;
    });
}

function loadNotifications(showAll = false) {
  const notificationList = document.getElementById("notificationList");
  let notificationContainer = document.getElementById("notificationContainer");

  if (!notificationContainer) {
    notificationContainer = document.createElement("div");
    notificationContainer.id = "notificationContainer";
    notificationList.insertBefore(notificationContainer, notificationList.firstChild);
  }

  notificationContainer.innerHTML = "";
  fetch(`/notifications/fetch_notifications${showAll ? "" : "?limit=5"}`)
    .then((response) => response.json())
    .then((notifications) => {
      if (notifications.length === 0) {
        document.getElementById("noNotificationsLabel").style.display = "block";
      } else {
        document.getElementById("noNotificationsLabel").style.display = "none";
      }
      notifications.forEach((notification) => {
        const notificationItem = createNotificationItem(notification);

        notificationItem.addEventListener("click", function (event) {
          event.preventDefault();

          fetch(`/notifications/${notification.id}/mark_as_read`, {
            method: "POST",
            headers: {
              "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
              "Content-Type": "application/json",
              Accept: "application/json"
            }
          })
            .then((response) => {
              if (!response.ok) {
                throw new Error("Network response was not ok");
              }
              return response.json();
            })
            .then((data) => {
              if (data.success) {
                notificationItem.classList.add("text-muted");
                window.location.href = notificationItem.href;
                updateButtons();
              }
            });
        });

        notificationContainer.appendChild(notificationItem);
      });
      updateButtons();
    });
}

function fetchNotifications() {
  const currentUserId = document.querySelector("body").dataset.currentUserId;

  if (currentUserId != "" && currentUserId != "1") {
    addClickListener(document.getElementById("showAllButton"), function () {
      loadNotifications(true);
      showAllButton.style.display = "none";
    });

    const markAllAsReadButton = document.getElementById("markAllAsReadButton");
    addClickListener(markAllAsReadButton, function () {
      fetchWithCsrfToken("/notifications/mark_all_as_read", "POST").then((data) => {
        if (data.success) {
          const notificationItems = document.querySelectorAll(".dropdown-item");
          const notificationBadge = document.getElementById("notificationBadge");
          notificationItems.forEach((item) => {
            item.classList.add("text-muted");
          });
          notificationBadge.innerText = 0;
          updateButtons();
        }
      });
    });

    const deleteReadNotificationsButton = document.getElementById("deleteReadNotificationsButton");
    addClickListener(deleteReadNotificationsButton, function () {
      fetchWithCsrfToken("/notifications/delete_read", "POST").then((data) => {
        if (data.success) {
          const notificationItems = document.querySelectorAll(".dropdown-item.text-muted");
          notificationItems.forEach((item) => {
            item.remove();
          });
          if (document.querySelectorAll(".dropdown-item").length == 0) {
            document.getElementById("noNotificationsLabel").style.display = "block";
          }
          updateButtons();
        }
      });
    });

    fetchNotificationsCount();
    loadNotifications();
    updateButtons();
  }
}

document.addEventListener("turbolinks:load", fetchNotifications);

async function fetchWithCsrfToken(url, method) {
  const response = await fetch(url, {
    method: method,
    headers: {
      "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
      "Content-Type": "application/json",
      Accept: "application/json"
    }
  });
  if (!response.ok) {
    throw new Error("Network response was not ok");
  }
  return await response.json();
}

function addClickListener(button, callback) {
  button.addEventListener("click", function (event) {
    event.stopPropagation();
    callback();
  });
}

function createNotificationItem(notification) {
  const notificationItem = document.createElement("a");
  notificationItem.classList.add("dropdown-item", "text-wrap", notification.read ? "text-muted" : "text-primary");
  notificationItem.href = `/projects/${notification.project_id}`;
  notificationItem.textContent = notification.message;
  return notificationItem;
}

function updateButtons() {
  const notificationItems = document.querySelectorAll(".dropdown-item");
  const readItems = document.querySelectorAll(".dropdown-item.text-muted");
  const unreadItems = notificationItems.length - readItems.length;
  const markAllAsReadButton = document.getElementById("markAllAsReadButton");
  const deleteReadNotificationsButton = document.getElementById("deleteReadNotificationsButton");
  const showAllButton = document.getElementById("showAllButton");

  markAllAsReadButton.style.display = unreadItems > 0 ? "block" : "none";
  deleteReadNotificationsButton.style.display = readItems.length > 0 ? "block" : "none";
  showAllButton.style.display = notificationItems.length > 5 ? "block" : "none";
}
