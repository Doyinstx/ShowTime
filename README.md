# ShowTime 🎭

A decentralized entertainment booking platform built on Stacks blockchain using Clarity smart contracts.

## Overview

ShowTime enables event organizers to create entertainment events and allows users to book tickets in a trustless, decentralized manner. The platform handles ticket sales, capacity management, and booking confirmations through smart contracts.

## Features

- **Event Creation**: Organizers can create entertainment events with custom pricing and capacity
- **Ticket Booking**: Users can securely book tickets with automatic capacity management
- **Platform Fee System**: Configurable platform fees for sustainable operations
- **Booking Management**: Track user bookings and event attendance
- **Event Cancellation**: Organizers can cancel events when necessary
- **Capacity Control**: Automatic prevention of overbooking

## Smart Contract Functions

### Public Functions

- `create-event`: Create a new entertainment event
- `book-ticket`: Book a ticket for an event
- `cancel-event`: Cancel an event (organizer only)
- `update-platform-fee`: Update platform fee (owner only)

### Read-Only Functions

- `get-event`: Retrieve event details
- `get-booking`: Get booking information
- `get-user-booking-count`: Get user's total bookings
- `get-platform-fee`: Get current platform fee
- `get-next-event-id`: Get next available event ID
- `tickets-available`: Check ticket availability

## Usage

### Creating an Event

```clarity
(contract-call? .showtime create-event 
  "Live Jazz Night" 
  "An evening of smooth jazz with local artists" 
  "Blue Note Cafe" 
  u1000000 
  u100 
  u2024001)
```

### Booking a Ticket

```clarity
(contract-call? .showtime book-ticket u1 u1050000)
```

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

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For questions or support, please open an issue in the repository.