import { Controller } from "@hotwired/stimulus";
import { FetchRequest } from "@rails/request.js";

// Enables drag-and-drop reordering of tasks across columns using HTML5 Drag API.
// Wire it up: data-controller="drag" on the board container.
// Columns:    data-drag-target="column" data-column-id="<id>" on each column wrapper.
// Task cards: data-drag-target="task"   data-task-id="<id>"  on each task card.
export default class extends Controller {
  static targets = ["task", "column"];

  connect() {
    this.draggedTask = null;
    this.originalColumn = null;
  }

  // Called when a task card's dragstart event fires
  dragstart(event) {
    const taskEl = event.target.closest("[data-drag-target='task']");
    if (!taskEl) return;

    this.draggedTask = taskEl;
    this.originalColumn = taskEl.closest("[data-drag-target='taskList']");
    event.dataTransfer.effectAllowed = "move";
    event.dataTransfer.setData("text/plain", taskEl.dataset.taskId);
    taskEl.classList.add("opacity-50");
  }

  dragend(event) {
    const taskEl = event.target.closest("[data-drag-target='task']");
    if (taskEl) taskEl.classList.remove("opacity-50");
    this.draggedTask = null;
  }

  dragover(event) {
    event.preventDefault();
    event.dataTransfer.dropEffect = "move";

    const taskList = event.target.closest("[data-drag-target='taskList']");
    if (!taskList) return;

    // Visual feedback: highlight target column
    this.columnTargets.forEach((col) =>
      col
        .querySelector("[data-drag-target='taskList']")
        ?.classList.remove("bg-indigo-50"),
    );
    taskList.classList.add("bg-indigo-50");
  }

  dragleave(event) {
    const taskList = event.target.closest("[data-drag-target='taskList']");
    if (taskList) taskList.classList.remove("bg-indigo-50");
  }

  async drop(event) {
    event.preventDefault();

    const taskList = event.target.closest("[data-drag-target='taskList']");
    if (!taskList || !this.draggedTask) return;

    taskList.classList.remove("bg-indigo-50");

    const taskId = this.draggedTask.dataset.taskId;
    const columnId = taskList.dataset.columnId;
    const moveUrl = this.draggedTask.dataset.moveUrl;

    if (!moveUrl) return;

    // Optimistically move the card in the DOM
    taskList.appendChild(this.draggedTask);

    // Calculate new position (index in the list)
    const tasks = Array.from(
      taskList.querySelectorAll("[data-drag-target='task']"),
    );
    const position = tasks.indexOf(this.draggedTask) + 1;

    // Fire PATCH move request
    const request = new FetchRequest("patch", moveUrl, {
      body: JSON.stringify({ column_id: columnId, position: position }),
      headers: { "Content-Type": "application/json" },
      responseKind: "turbo-stream",
    });
    await request.perform();
  }
}
