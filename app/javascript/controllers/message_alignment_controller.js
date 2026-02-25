import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.align()

        // Use MutationObserver to style messages appended via Turbo Streams
        this.observer = new MutationObserver(() => this.align())
        this.observer.observe(this.element, { childList: true })
    }

    disconnect() {
        if (this.observer) this.observer.disconnect()
    }

    align() {
        const currentUserId = this.element.dataset.currentUserId
        const messages = this.element.querySelectorAll(".message")
        console.log(`Aligning ${messages.length} messages for user ${currentUserId}`)

        messages.forEach((message) => {
            if (message.dataset.userId === currentUserId) {
                message.classList.add("sent")
                message.classList.remove("received")
            } else {
                message.classList.add("received")
                message.classList.remove("sent")
            }
        })
    }
}
