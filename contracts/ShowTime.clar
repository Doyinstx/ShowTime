;; ShowTime - Entertainment Booking Platform
;; A decentralized platform for booking entertainment events with multi-tier pricing

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
(define-constant err-invalid-ticket-type (err u108))
(define-constant err-tier-full (err u109))
(define-constant err-invalid-string (err u110))

;; Ticket type constants
(define-constant ticket-type-early-bird u1)
(define-constant ticket-type-regular u2)
(define-constant ticket-type-vip u3)

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
    early-bird-price: uint,
    regular-price: uint,
    vip-price: uint,
    early-bird-capacity: uint,
    regular-capacity: uint,
    vip-capacity: uint,
    early-bird-sold: uint,
    regular-sold: uint,
    vip-sold: uint,
    is-active: bool,
    event-date: uint,
    early-bird-deadline: uint
  }
)

(define-map bookings
  { event-id: uint, attendee: principal }
  {
    booking-id: uint,
    ticket-type: uint,
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
  (and (> (len input) u0) (<= (len input) u100))
)

(define-private (validate-description (input (string-ascii 500)))
  (and (> (len input) u0) (<= (len input) u500))
)

(define-private (increment-booking-count (user principal))
  (let ((current-count (default-to u0 (get count (map-get? user-booking-count { user: user })))))
    (map-set user-booking-count { user: user } { count: (+ current-count u1) })
  )
)

(define-private (calculate-platform-fee (amount uint))
  (/ (* amount (var-get platform-fee)) u1000)
)

(define-private (is-valid-ticket-type (ticket-type uint))
  (or (is-eq ticket-type ticket-type-early-bird)
      (or (is-eq ticket-type ticket-type-regular)
          (is-eq ticket-type ticket-type-vip)))
)

(define-private (get-ticket-price (event-data (tuple (organizer principal) (title (string-ascii 100)) (description (string-ascii 500)) (venue (string-ascii 100)) (early-bird-price uint) (regular-price uint) (vip-price uint) (early-bird-capacity uint) (regular-capacity uint) (vip-capacity uint) (early-bird-sold uint) (regular-sold uint) (vip-sold uint) (is-active bool) (event-date uint) (early-bird-deadline uint))) (ticket-type uint))
  (if (is-eq ticket-type ticket-type-early-bird)
    (get early-bird-price event-data)
    (if (is-eq ticket-type ticket-type-regular)
      (get regular-price event-data)
      (get vip-price event-data)))
)

(define-private (get-tickets-sold (event-data (tuple (organizer principal) (title (string-ascii 100)) (description (string-ascii 500)) (venue (string-ascii 100)) (early-bird-price uint) (regular-price uint) (vip-price uint) (early-bird-capacity uint) (regular-capacity uint) (vip-capacity uint) (early-bird-sold uint) (regular-sold uint) (vip-sold uint) (is-active bool) (event-date uint) (early-bird-deadline uint))) (ticket-type uint))
  (if (is-eq ticket-type ticket-type-early-bird)
    (get early-bird-sold event-data)
    (if (is-eq ticket-type ticket-type-regular)
      (get regular-sold event-data)
      (get vip-sold event-data)))
)

(define-private (get-tier-capacity (event-data (tuple (organizer principal) (title (string-ascii 100)) (description (string-ascii 500)) (venue (string-ascii 100)) (early-bird-price uint) (regular-price uint) (vip-price uint) (early-bird-capacity uint) (regular-capacity uint) (vip-capacity uint) (early-bird-sold uint) (regular-sold uint) (vip-sold uint) (is-active bool) (event-date uint) (early-bird-deadline uint))) (ticket-type uint))
  (if (is-eq ticket-type ticket-type-early-bird)
    (get early-bird-capacity event-data)
    (if (is-eq ticket-type ticket-type-regular)
      (get regular-capacity event-data)
      (get vip-capacity event-data)))
)

(define-private (is-early-bird-available (event-data (tuple (organizer principal) (title (string-ascii 100)) (description (string-ascii 500)) (venue (string-ascii 100)) (early-bird-price uint) (regular-price uint) (vip-price uint) (early-bird-capacity uint) (regular-capacity uint) (vip-capacity uint) (early-bird-sold uint) (regular-sold uint) (vip-sold uint) (is-active bool) (event-date uint) (early-bird-deadline uint))))
  (and (< (get early-bird-sold event-data) (get early-bird-capacity event-data))
       (<= stacks-block-height (get early-bird-deadline event-data)))
)

;; Public Functions

;; Create a new entertainment event with multi-tier pricing
(define-public (create-event 
  (title (string-ascii 100))
  (description (string-ascii 500))
  (venue (string-ascii 100))
  (early-bird-price uint)
  (regular-price uint)
  (vip-price uint)
  (early-bird-capacity uint)
  (regular-capacity uint)
  (vip-capacity uint)
  (event-date uint)
  (early-bird-deadline uint)
)
  (let ((event-id (var-get next-event-id)))
    (asserts! (> early-bird-price u0) err-invalid-amount)
    (asserts! (> regular-price u0) err-invalid-amount)
    (asserts! (> vip-price u0) err-invalid-amount)
    (asserts! (> early-bird-capacity u0) err-invalid-amount)
    (asserts! (> regular-capacity u0) err-invalid-amount)
    (asserts! (> vip-capacity u0) err-invalid-amount)
    (asserts! (> event-date u0) err-invalid-amount)
    (asserts! (> early-bird-deadline u0) err-invalid-amount)
    (asserts! (< early-bird-deadline event-date) err-invalid-amount)
    (asserts! (< early-bird-price regular-price) err-invalid-amount)
    (asserts! (< regular-price vip-price) err-invalid-amount)
    (asserts! (validate-string title) err-invalid-string)
    (asserts! (validate-description description) err-invalid-string)
    (asserts! (validate-string venue) err-invalid-string)
    (map-set events
      { event-id: event-id }
      {
        organizer: tx-sender,
        title: title,
        description: description,
        venue: venue,
        early-bird-price: early-bird-price,
        regular-price: regular-price,
        vip-price: vip-price,
        early-bird-capacity: early-bird-capacity,
        regular-capacity: regular-capacity,
        vip-capacity: vip-capacity,
        early-bird-sold: u0,
        regular-sold: u0,
        vip-sold: u0,
        is-active: true,
        event-date: event-date,
        early-bird-deadline: early-bird-deadline
      }
    )
    (var-set next-event-id (+ event-id u1))
    (ok event-id)
  )
)

;; Book tickets for an event with specific tier
(define-public (book-ticket (event-id uint) (ticket-type uint) (payment uint))
  (let (
    (event-data (unwrap! (map-get? events { event-id: event-id }) err-not-found))
    (existing-booking (map-get? bookings { event-id: event-id, attendee: tx-sender }))
    (ticket-price (get-ticket-price event-data ticket-type))
    (fee-amount (calculate-platform-fee ticket-price))
    (total-required (+ ticket-price fee-amount))
    (tickets-sold (get-tickets-sold event-data ticket-type))
    (tier-capacity (get-tier-capacity event-data ticket-type))
  )
    (asserts! (> event-id u0) err-invalid-amount)
    (asserts! (> payment u0) err-invalid-amount)
    (asserts! (is-valid-ticket-type ticket-type) err-invalid-ticket-type)
    (asserts! (get is-active event-data) err-event-not-active)
    (asserts! (is-none existing-booking) err-booking-exists)
    (asserts! (< tickets-sold tier-capacity) err-tier-full)
    (asserts! (>= payment total-required) err-insufficient-payment)
    
    ;; Check early bird availability
    (if (is-eq ticket-type ticket-type-early-bird)
      (asserts! (is-early-bird-available event-data) err-event-not-active)
      true
    )
    
    ;; Create booking
    (map-set bookings
      { event-id: event-id, attendee: tx-sender }
      {
        booking-id: (+ (* event-id u10000) (+ (* ticket-type u1000) tickets-sold)),
        ticket-type: ticket-type,
        amount-paid: payment,
        booking-timestamp: stacks-block-height,
        is-confirmed: true
      }
    )
    
    ;; Update event booking count for specific tier
    (if (is-eq ticket-type ticket-type-early-bird)
      (map-set events
        { event-id: event-id }
        (merge event-data { early-bird-sold: (+ (get early-bird-sold event-data) u1) })
      )
      (if (is-eq ticket-type ticket-type-regular)
        (map-set events
          { event-id: event-id }
          (merge event-data { regular-sold: (+ (get regular-sold event-data) u1) })
        )
        (map-set events
          { event-id: event-id }
          (merge event-data { vip-sold: (+ (get vip-sold event-data) u1) })
        )
      )
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

;; Check if specific ticket tier has available tickets
(define-read-only (tier-tickets-available (event-id uint) (ticket-type uint))
  (begin
    (asserts! (> event-id u0) err-invalid-amount)
    (asserts! (is-valid-ticket-type ticket-type) err-invalid-ticket-type)
    (ok (match (map-get? events { event-id: event-id })
      event-data 
        (if (is-eq ticket-type ticket-type-early-bird)
          (is-early-bird-available event-data)
          (< (get-tickets-sold event-data ticket-type) (get-tier-capacity event-data ticket-type))
        )
      false
    ))
  )
)

;; Get ticket price for specific tier
(define-read-only (get-tier-price (event-id uint) (ticket-type uint))
  (begin
    (asserts! (> event-id u0) err-invalid-amount)
    (asserts! (is-valid-ticket-type ticket-type) err-invalid-ticket-type)
    (ok (match (map-get? events { event-id: event-id })
      event-data (some (get-ticket-price event-data ticket-type))
      none
    ))
  )
)

;; Get total tickets sold for an event
(define-read-only (get-total-tickets-sold (event-id uint))
  (begin
    (asserts! (> event-id u0) err-invalid-amount)
    (ok (match (map-get? events { event-id: event-id })
      event-data (some (+ (+ (get early-bird-sold event-data) (get regular-sold event-data)) (get vip-sold event-data)))
      none
    ))
  )
)

;; Get tier-specific sales data
(define-read-only (get-tier-sales (event-id uint))
  (begin
    (asserts! (> event-id u0) err-invalid-amount)
    (ok (match (map-get? events { event-id: event-id })
      event-data (some {
        early-bird-sold: (get early-bird-sold event-data),
        regular-sold: (get regular-sold event-data),
        vip-sold: (get vip-sold event-data),
        early-bird-capacity: (get early-bird-capacity event-data),
        regular-capacity: (get regular-capacity event-data),
        vip-capacity: (get vip-capacity event-data)
      })
      none
    ))
  )
)