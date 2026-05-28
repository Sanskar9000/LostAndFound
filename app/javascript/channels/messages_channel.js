import consumer from "channels/consumer"

let activeConversationId = null
let subscription = null

const disconnectConversation = () => {
  if (subscription) {
    consumer.subscriptions.remove(subscription)
    subscription = null
  }
  activeConversationId = null
}

const scrollMessagesToBottom = () => {
  const container = document.getElementById("conversationMessages")
  if (!container) return
  container.scrollTop = container.scrollHeight
}

const appendMessage = (html) => {
  const container = document.getElementById("conversationMessages")
  if (!container || !html) return
  container.insertAdjacentHTML("beforeend", html)
  scrollMessagesToBottom()
}

const connectConversation = () => {
  const container = document.getElementById("conversationMessages")

  if (!container) {
    disconnectConversation()
    return
  }

  const conversationId = container.dataset.conversationId
  if (!conversationId) {
    disconnectConversation()
    return
  }

  if (activeConversationId === conversationId && subscription) {
    scrollMessagesToBottom()
    return
  }

  disconnectConversation()
  activeConversationId = conversationId

  subscription = consumer.subscriptions.create(
    { channel: "MessagesChannel", conversation_id: conversationId },
    {
      connected() {
        scrollMessagesToBottom()
      },

      received(data) {
        if (String(data.conversation_id) !== String(activeConversationId)) return
        appendMessage(data.message_html)
      }
    }
  )
}

document.addEventListener("turbo:load", connectConversation)
document.addEventListener("turbo:before-cache", disconnectConversation)
