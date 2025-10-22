# ShowTime 🎭

A decentralized entertainment booking platform built on Stacks blockchain using Clarity smart contracts with **multi-tier pricing** support, **automated refund system**, and **event rating & reviews**.

## Overview

ShowTime enables event organizers to create entertainment events with flexible pricing tiers and allows users to book tickets in a trustless, decentralized manner. The platform handles ticket sales across multiple tiers (Early Bird, Regular, VIP), capacity management, booking confirmations, automated refunds for cancelled events, and post-event ratings and reviews through smart contracts with STX escrow.

## Features

- **Multi-tier Pricing**: Support for Early Bird, Regular, and VIP ticket categories with different pricing
- **Event Creation**: Organizers can create entertainment events with custom pricing and capacity for each tier
- **Flexible Ticket Booking**: Users can securely book tickets from available tiers with automatic capacity management
- **Automated Refund System**: STX escrow mechanism with automatic refunds for cancelled events
- **Event Rating & Reviews**: Attendees can rate and review events after completion with verified attendance
- **Review Aggregation**: Automatic calculation of average ratings and review counts
- **Early Bird Sales**: Time-limited early bird tickets with special pricing
- **VIP Experience**: Premium ticket tier with enhanced pricing
- **Platform Fee System**: Configurable platform fees for sustainable operations
- **Booking Management**: Track user bookings and event attendance across all tiers
- **Event Cancellation**: Organizers can cancel events with automatic refund processing
- **Tier-specific Capacity Control**: Automatic prevention of overbooking per tier
- **Escrow Protection**: All ticket payments held in escrow until event completion or cancellation
- **Advanced Analytics**: Track sales performance and event ratings across different ticket tiers

## Ticket Tiers

### 1. Early Bird Tickets
- **Price**: Lowest tier pricing
- **Availability**: Time-limited (until early-bird-deadline)
- **Capacity**: Limited quantity set by organizer
- **Benefits**: Significant cost savings for early purchasers
- **Refund**: Full refund if event cancelled
- **Review Rights**: Can review after event completion

### 2. Regular Tickets
- **Price**: Standard pricing
- **Availability**: Throughout the sales period
- **Capacity**: Main ticket allocation
- **Benefits**: Standard event access
- **Refund**: Full refund if event cancelled
- **Review Rights**: Can review after event completion

### 3. VIP Tickets
- **Price**: Premium pricing
- **Availability**: Throughout the sales period
- **Capacity**: Limited premium allocation
- **Benefits**: Enhanced experience (implementation dependent)
- **Refund**: Full refund if event cancelled
- **Review Rights**: Can review after event completion

## Rating & Review System

The platform features a comprehensive rating and review system with verified attendance:

### Rating Features
- **5-Star Rating System**: Rate events from 1 to 5 stars
- **Verified Attendees Only**: Only confirmed ticket holders can review
- **Post-Event Reviews**: Reviews allowed only after event completion
- **One Review Per User**: Each attendee can submit one review per event
- **Automatic Aggregation**: Average ratings calculated automatically

### Review Features
- **Written Reviews**: Text-based feedback up to 500 characters
- **Timestamp Tracking**: All reviews timestamped for transparency
- **Immutable Records**: Reviews stored permanently on blockchain
- **Review Discovery**: Query reviews by event or user
- **Rating Statistics**: View average ratings and total review counts

### Review Validation
- Must be a confirmed ticket holder
- Event must be completed (past event date)
- Rating must be between 1-5 stars
- Review text must be between 1-500 characters
- One review per event per user

## Refund System

The platform features an automated STX escrow system that provides:

### Escrow Protection
- All ticket payments are held in contract escrow
- Funds released to organizer only after successful event completion
- Platform fees deducted only from successful events

### Automatic Refunds
- Event cancellation triggers automatic refund eligibility
- Users can claim full refunds for cancelled events
- No fees charged on refunded tickets

### Refund Process
1. **Event Cancellation**: Organizer cancels event using `cancel-event`
2. **Refund Eligibility**: All attendees become eligible for full refunds
3. **Claim Refund**: Users call `claim-refund` to receive their STX back
4. **Automatic Processing**: Contract handles refund calculation and transfer

## Smart Contract Functions

### Public Functions

- `create-event`: Create a new entertainment event with multi-tier pricing
- `book-ticket`: Book a ticket for a specific tier of an event
- `cancel-event`: Cancel an event (organizer only) - triggers refund eligibility
- `claim-refund`: Claim refund for cancelled event (attendees only)
- `release-event-funds`: Release escrow funds to organizer after successful event
- `submit-review`: Submit rating and review for completed event (verified attendees only)
- `update-platform-fee`: Update platform fee (owner only)

### Read-Only Functions

- `get-event`: Retrieve complete event details including all tiers
- `get-booking`: Get booking information with tier details
- `get-user-booking-count`: Get user's total bookings across all events
- `get-platform-fee`: Get current platform fee
- `get-next-event-id`: Get next available event ID
- `tier-tickets-available`: Check ticket availability for specific tier
- `get-tier-price`: Get price for specific ticket tier
- `get-total-tickets-sold`: Get total tickets sold across all tiers
- `get-tier-sales`: Get detailed sales breakdown by tier
- `get-escrow-balance`: Get total STX held in escrow for an event
- `is-refund-eligible`: Check if user is eligible for refund
- `get-refund-amount`: Get refund amount for a user's booking
- `get-review`: Get a specific user's review for an event
- `get-event-rating`: Get average rating and total reviews for an event
- `get-user-reviews`: Get all reviews submitted by a specific user
- `can-review-event`: Check if user is eligible to review an event

## Usage

### Creating an Event with Multi-tier Pricing

```clarity
(contract-call? .showtime create-event 
  "Live Jazz Night" 
  "An evening of smooth jazz with local artists" 
  "Blue Note Cafe" 
  u800000   ;; Early bird price (0.8 STX)
  u1000000  ;; Regular price (1.0 STX)
  u1500000  ;; VIP price (1.5 STX)
  u20       ;; Early bird capacity
  u100      ;; Regular capacity  
  u10       ;; VIP capacity
  u2024365  ;; Event date (block height)
  u2024300) ;; Early bird deadline (block height)
```

### Booking Different Ticket Types

```clarity
;; Book Early Bird ticket (type 1)
(contract-call? .showtime book-ticket u1 u1 u840000)

;; Book Regular ticket (type 2)  
(contract-call? .showtime book-ticket u1 u2 u1050000)

;; Book VIP ticket (type 3)
(contract-call? .showtime book-ticket u1 u3 u1575000)
```

### Rating & Review System Usage

```clarity
;; Submit a review after attending event
(contract-call? .showtime submit-review 
  u1                                    ;; event-id
  u5                                    ;; rating (1-5 stars)
  "Amazing performance! Great venue!")  ;; review text

;; Check if you can review an event
(contract-call? .showtime can-review-event u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Get event's average rating and review count
(contract-call? .showtime get-event-rating u1)

;; Get a specific user's review
(contract-call? .showtime get-review u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Get all reviews by a user
(contract-call? .showtime get-user-reviews 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### Refund System Usage

```clarity
;; Cancel event (organizer only)
(contract-call? .showtime cancel-event u1)

;; Claim refund after cancellation (attendees)
(contract-call? .showtime claim-refund u1)

;; Check refund eligibility
(contract-call? .showtime is-refund-eligible u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Release funds after successful event (organizer)
(contract-call? .showtime release-event-funds u1)
```

### Checking Tier Availability

```clarity
;; Check if Early Bird tickets are available
(contract-call? .showtime tier-tickets-available u1 u1)

;; Check VIP ticket availability
(contract-call? .showtime tier-tickets-available u1 u3)
```

### Getting Tier Information

```clarity
;; Get price for VIP tickets
(contract-call? .showtime get-tier-price u1 u3)

;; Get sales breakdown by tier
(contract-call? .showtime get-tier-sales u1)

;; Get escrow balance for event
(contract-call? .showtime get-escrow-balance u1)
```

## Ticket Type Constants

- `ticket-type-early-bird`: `u1` - Early bird discount tickets
- `ticket-type-regular`: `u2` - Standard priced tickets  
- `ticket-type-vip`: `u3` - Premium priced tickets

## Pricing Logic

The contract enforces the following pricing hierarchy:
```
Early Bird Price < Regular Price < VIP Price
```

This ensures logical pricing progression across tiers.

## Error Codes

- `u100`: Owner only operation
- `u101`: Event/booking not found
- `u102`: Unauthorized access
- `u103`: Invalid amount
- `u104`: Event at capacity (legacy)
- `u105`: Event not active or early bird expired
- `u106`: Booking already exists
- `u107`: Insufficient payment
- `u108`: Invalid ticket type
- `u109`: Specific tier is full
- `u110`: Invalid string input
- `u111`: Refund already claimed
- `u112`: Not eligible for refund
- `u113`: Event not cancelled
- `u114`: Insufficient contract balance
- `u115`: Event already completed
- `u116`: Invalid rating value
- `u117`: Review already submitted
- `u118`: Event not completed yet
- `u119`: Not a verified attendee

## Installation

1. Install Clarinet CLI
2. Clone this repository
3. Run `clarinet check` to verify contract syntax
4. Deploy to testnet or mainnet

## Testing

Run the test suite with:
```bash
clarinet test
```

Test scenarios should cover:
- Multi-tier event creation
- Booking across different tiers
- Early bird deadline enforcement
- Capacity management per tier
- Price validation and hierarchy
- Event cancellation and refunds
- Escrow fund management
- Fund release after successful events
- Rating and review submission
- Review eligibility validation
- Rating aggregation and statistics

## API Integration Examples

### JavaScript/TypeScript Integration

```typescript
// Example booking function
async function bookTicket(eventId: number, tierType: number, payment: number) {
  const result = await contractCall({
    contractAddress: CONTRACT_ADDRESS,
    contractName: 'showtime',
    functionName: 'book-ticket',
    functionArgs: [
      uintCV(eventId),
      uintCV(tierType), // 1=early-bird, 2=regular, 3=vip
      uintCV(payment)
    ],
  });
  return result;
}

// Example refund claim function
async function claimRefund(eventId: number) {
  const result = await contractCall({
    contractAddress: CONTRACT_ADDRESS,
    contractName: 'showtime',
    functionName: 'claim-refund',
    functionArgs: [
      uintCV(eventId)
    ],
  });
  return result;
}

// Example review submission function
async function submitReview(eventId: number, rating: number, reviewText: string) {
  const result = await contractCall({
    contractAddress: CONTRACT_ADDRESS,
    contractName: 'showtime',
    functionName: 'submit-review',
    functionArgs: [
      uintCV(eventId),
      uintCV(rating),
      stringAsciiCV(reviewText)
    ],
  });
  return result;
}

// Example get event rating function
async function getEventRating(eventId: number) {
  const result = await contractCallReadOnly({
    contractAddress: CONTRACT_ADDRESS,
    contractName: 'showtime',
    functionName: 'get-event-rating',
    functionArgs: [
      uintCV(eventId)
    ],
  });
  return result;
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new rating and review functionality
5. Submit a pull request

## Roadmap

- [x] **Refund System**: Add automated refund mechanism for cancelled events with STX escrow ✅
- [x] **Event Rating & Reviews**: Allow attendees to rate and review events after completion ✅
- [ ] **Loyalty Program**: Implement reward points for frequent event attendees
- [ ] **Group Booking Discounts**: Add functionality for bulk ticket purchases with automatic discounts
- [ ] **Event Streaming Integration**: Connect with streaming platforms for hybrid physical/virtual events
- [ ] **Artist Royalty Distribution**: Automatically distribute ticket revenue to performers based on contracts
- [ ] **Seat Selection**: Add venue mapping and specific seat selection for assigned seating events
- [ ] **Secondary Market**: Enable secure ticket resale marketplace with price controls
- [ ] **Social Features**: Add event sharing, friend invitations, and social proof mechanisms

---

**Note**: This implementation provides a foundation for multi-tier ticketing with automated refunds and event ratings. The escrow system ensures both organizers and attendees are protected, with automatic refund processing for cancelled events, secure fund release for successful events, and verified attendee reviews for community feedback.