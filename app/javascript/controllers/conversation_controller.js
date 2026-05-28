import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["messages", "form", "input"]
  static values = {
    conversationId: Number,
    currentUserId: Number
  }

  connect() {
    this.subscription = consumer.subscriptions.create(
      { channel: "MessagesChannel", conversation_id: this.conversationIdValue },
      {
        connected: () => this.scrollToBottom(),
        received: (data) => this.received(data)
      }
    )

    this.scrollToBottom()
  }

  disconnect() {
    if (this.subscription) {
      consumer.subscriptions.remove(this.subscription)
      this.subscription = null
    }
  }

  handleSubmitEnd(event) {
    if (!event.detail.success) return

    this.formTarget.reset()
    this.scrollToBottom()
    this.focusInput()
  }

  submitOnEnter(event) {
    if (event.key !== "Enter" || event.shiftKey) return

    event.preventDefault()
    this.formTarget.requestSubmit()
  }

  received(data) {
    if (String(data.conversation_id) !== String(this.conversationIdValue)) return
    if (!data.message) return

    this.messagesTarget.insertAdjacentHTML("beforeend", this.messageMarkup(data.message))
    this.scrollToBottom()
  }

  messageMarkup(message) {
    const mine = Number(message.sender_id) === this.currentUserIdValue
    const wrapperClass = mine ? "justify-content-end" : "justify-content-start"
    const bubbleClass = mine ? "bg-dark text-white" : "card card-soft border-0"
    const metaClass = mine ? "text-white-50" : "text-muted"
    const senderLabel = mine ? "You" : this.escapeHtml(message.sender_email)

    return `
      <div class="d-flex ${wrapperClass} mb-3">
        <div class="p-3 rounded-4 ${bubbleClass}" style="max-width: min(82%, 520px);">
          <div class="small ${metaClass} mb-1">${senderLabel}</div>
          <div>${this.formatBody(message.body)}</div>
          <div class="small ${metaClass} mt-2">${this.escapeHtml(message.created_at_label)}</div>
        </div>
      </div>
    `
  }

  formatBody(body) {
    const escaped = this.escapeHtml(body || "")
    const paragraphs = escaped.split(/\n{2,}/).map((chunk) => `<p>${chunk.replace(/\n/g, "<br>")}</p>`)
    return paragraphs.join("")
  }

  escapeHtml(value) {
    return String(value)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;")
  }

  scrollToBottom() {
    if (!this.hasMessagesTarget) return
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  focusInput() {
    if (this.hasInputTarget) {
      this.inputTarget.focus()
    }
  }
}
