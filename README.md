# ShowTime 🎭

A decentralized entertainment booking platform built on Stacks blockchain using Clarity smart contracts with **multi-tier pricing** support.

## Overview

ShowTime enables event organizers to create entertainment events with flexible pricing tiers and allows users to book tickets in a trustless, decentralized manner. The platform handles ticket sales across multiple tiers (Early Bird, Regular, VIP), capacity management, and booking confirmations through smart contracts.

## Features

- **Multi-tier Pricing**: Support for Early Bird, Regular, and VIP ticket categories with different pricing
- **Event Creation**: Organizers can create entertainment events with custom pricing and capacity for each tier
- **Flexible Ticket Booking**: Users can securely book tickets from available tiers with automatic capacity management
- **Early Bird Sales**: Time-limited early bird tickets with special pricing
- **VIP Experience**: Premium ticket tier with enhanced pricing
- **Platform Fee System**: Configurable platform fees for sustainable operations
- **Booking Management**: Track user bookings and event attendance across all tiers
- **Event Cancellation**: Organizers can cancel events when necessary
- **Tier-specific Capacity Control**: Automatic prevention of overbooking per tier
- **Advanced Analytics**: Track sales performance across different ticket tiers

## Ticket Tiers

### 1. Early Bird Tickets
- **Price**: Lowest tier pricing
- **Availability**: Time-limited (until early-bird-deadline)
- **Capacity**: Limited quantity set by organizer
- **Benefits**: Significant cost savings for early purchasers

### 2. Regular Tickets
- **Price**: Standard pricing
- **Availability**: Throughout the sales period
- **Capacity**: Main ticket allocation
- **Benefits**: Standard event access

### 3. VIP Tickets
- **Price**: Premium pricing
- **Availability**: Throughout the sales period
- **Capacity**: Limited premium allocation
- **Benefits**: Enhanced experience (implementation dependent)

## Smart Contract Functions

### Public Functions

- `create-event`: Create a new entertainment event with multi-tier pricing
- `book-ticket`: Book a ticket for a specific tier of an event
- `cancel-event`: Cancel an event (organizer only)
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
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new tier functionality
5. Submit a pull request

## Roadmap

- [ ] **Refund System**: Add automated refund mechanism for cancelled events with STX escrow
- [ ] **Event Rating & Reviews**: Allow attendees to rate and review events after completion
- [ ] **Loyalty Program**: Implement reward points for frequent event attendees
- [ ] **Group Booking Discounts**: Add functionality for bulk ticket purchases with automatic discounts
- [ ] **Event Streaming Integration**: Connect with streaming platforms for hybrid physical/virtual events
- [ ] **Artist Royalty Distribution**: Automatically distribute ticket revenue to performers based on contracts
- [ ] **Seat Selection**: Add venue mapping and specific seat selection for assigned seating events
- [ ] **Secondary Market**: Enable secure ticket resale marketplace with price controls
- [ ] **Social Features**: Add event sharing, friend invitations, and social proof mechanisms

---

**Note**: This implementation provides a foundation for multi-tier ticketing. Event organizers should consider additional off-chain services for enhanced VIP experiences and customer support.