;; ShowTime - Entertainment Booking Platform
;; A decentralized platform for booking entertainment events

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-event-full (err u104))
(define-constant err-event-not-active (err u105))
(define-constant err-booking-exists (err u106))
(define-constant err-insufficient-payment (err u107))

;; Data Variables
(define-data-var next-event-id uint u1)
(define-data-var platform-fee uint u50) ;; 5% platform fee

;; Data Maps
(define-map events
  { event-id: uint }
  {
    organizer: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    venue: (string-ascii 100),
    ticket-price: uint,
    max-capacity: uint,
    current-bookings: uint,
    is-active: bool,
    event-date: uint
  }
)

(define-map bookings
  { event-id: uint, attendee: principal }
  {
    booking-id: uint,
    amount-paid: uint,
    booking-timestamp: uint,
    is-confirmed: bool
  }
)

(define-map user-booking-count
  { user: principal }
  { count: uint }
)

;; Private Functions
(define-private (validate-string (input (string-ascii 100)))
  (> (len input) u0)
)

(define-private (validate-venue (input (string-ascii 100)))
  (> (len input) u0)
)

(define-private (validate-description (input (string-ascii 500)))
  (> (len input) u0)
)

(define-private (increment-booking-count (user principal))
  (let ((current-count (default-to u0 (get count (map-get? user-booking-count { user: user })))))
    (map-set user-booking-count { user: user } { count: (+ current-count u1) })
  )
)

(define-private (calculate-platform-fee (amount uint))
  (/ (* amount (var-get platform-fee)) u1000)
)

;; Public Functions

;; Create a new entertainment event
(define-public (create-event 
  (title (string-ascii 100))
  (description (string-ascii 500))
  (venue (string-ascii 100))
  (ticket-price uint)
  (max-capacity uint)
  (event-date uint)
)
  (let ((event-id (var-get next-event-id)))
    (asserts! (> ticket-price u0) err-invalid-amount)
    (asserts! (> max-capacity u0) err-invalid-amount)
    (asserts! (> event-date u0) err-invalid-amount)
    (asserts! (validate-string title) err-invalid-amount)
    (asserts! (validate-description description) err-invalid-amount)
    (asserts! (validate-venue venue) err-invalid-amount)
    (map-set events
      { event-id: event-id }
      {
        organizer: tx-sender,
        title: title,
        description: description,
        venue: venue,
        ticket-price: ticket-price,
        max-capacity: max-capacity,
        current-bookings: u0,
        is-active: true,
        event-date: event-date
      }
    )
    (var-set next-event-id (+ event-id u1))
    (ok event-id)
  )
)

;; Book tickets for an event
(define-public (book-ticket (event-id uint) (payment uint))
  (let (
    (event-data (unwrap! (map-get? events { event-id: event-id }) err-not-found))
    (existing-booking (map-get? bookings { event-id: event-id, attendee: tx-sender }))
    (fee-amount (calculate-platform-fee (get ticket-price event-data)))
    (total-required (+ (get ticket-price event-data) fee-amount))
  )
    (asserts! (> event-id u0) err-invalid-amount)
    (asserts! (> payment u0) err-invalid-amount)
    (asserts! (get is-active event-data) err-event-not-active)
    (asserts! (is-none existing-booking) err-booking-exists)
    (asserts! (< (get current-bookings event-data) (get max-capacity event-data)) err-event-full)
    (asserts! (>= payment total-required) err-insufficient-payment)
    
    ;; Create booking
    (map-set bookings
      { event-id: event-id, attendee: tx-sender }
      {
        booking-id: (+ (* event-id u1000) (get current-bookings event-data)),
        amount-paid: payment,
        booking-timestamp: stacks-block-height,
        is-confirmed: true
      }
    )
    
    ;; Update event booking count
    (map-set events
      { event-id: event-id }
      (merge event-data { current-bookings: (+ (get current-bookings event-data) u1) })
    )
    
    ;; Update user booking count
    (increment-booking-count tx-sender)
    
    (ok true)
  )
)

;; Cancel an event (organizer only)
(define-public (cancel-event (event-id uint))
  (let ((event-data (unwrap! (map-get? events { event-id: event-id }) err-not-found)))
    (asserts! (> event-id u0) err-invalid-amount)
    (asserts! (is-eq tx-sender (get organizer event-data)) err-unauthorized)
    (map-set events
      { event-id: event-id }
      (merge event-data { is-active: false })
    )
    (ok true)
  )
)

;; Update platform fee (contract owner only)
(define-public (update-platform-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-fee u1000) err-invalid-amount) ;; Max 100% fee
    (var-set platform-fee new-fee)
    (ok true)
  )
)

;; Read-only Functions

;; Get event details
(define-read-only (get-event (event-id uint))
  (begin
    (asserts! (> event-id u0) err-invalid-amount)
    (ok (map-get? events { event-id: event-id }))
  )
)

;; Get booking details
(define-read-only (get-booking (event-id uint) (attendee principal))
  (begin
    (asserts! (> event-id u0) err-invalid-amount)
    (ok (map-get? bookings { event-id: event-id, attendee: attendee }))
  )
)

;; Get user's total bookings
(define-read-only (get-user-booking-count (user principal))
  (default-to u0 (get count (map-get? user-booking-count { user: user })))
)

;; Get platform fee
(define-read-only (get-platform-fee)
  (var-get platform-fee)
)

;; Get next event ID
(define-read-only (get-next-event-id)
  (var-get next-event-id)
)

;; Check if event has available tickets
(define-read-only (tickets-available (event-id uint))
  (begin
    (asserts! (> event-id u0) err-invalid-amount)
    (ok (match (map-get? events { event-id: event-id })
      event-data (< (get current-bookings event-data) (get max-capacity event-data))
      false
    ))
  )
)