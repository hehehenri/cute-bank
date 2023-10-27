# Cute Bank

## Getting Started

1. **Clone and Install**
   - Clone the repository and install the required dependencies.
```bash
git clone git@github.com:hnrbs/cute-bank.git
mix deps.get
```

2. **Build Containers**
   - Set up your database configuration and any environment-specific settings.
```bash
docker-compose up -d
```

3. **Database Migration**
   - Run database migrations to create the necessary tables.
```bash
mix ecto.create
mix ecto.migrate
```

4. **Running the Application**
   - Start the application and ensure it's accessible.
```bash
mix phx.server
```

## Authentication

Authentication is required for some of the endpoints. Make sure to include appropriate authentication tokens in your requests when accessing protected routes.

## API Endpoints

### Health Check

- **GET** `/api/health_check`
  - Endpoint for checking the health status of the system.

### User Management

- **POST** `/api/user/create`
  - Create a new user account.
```json
{
  "user": {
    "first_name": "John",
    "last_name": "Doe",
    "": "000.000.000-00",
    "password": "s3cure_pa$sword",
  }
}
```
- **POST** `/api/user/login`
  - Log in an existing user.
```json
{
  "": "000.000.000-00",
  "password": "s3cure_pa$sword"
}
```

### Transaction Management

- **POST** `/api/transaction/create`
  - Create a new transaction.
```json
{
  "transaction": {
    "amount": 5000,
    "receiver_": "000.000.000-00",
  }
}
```
- **POST** `/api/transaction/refund`
  - Initiate a refund for a transaction.
```json
{
  "transaction_id": "01ec23e3-6a91-4a0a-9b01-291b27f6ee3f"
}
```
- **GET** `/api/transaction`
  - Retrieve a list of transactions.

### Balance Management

- **POST** `/api/balance/withdraw`
  - Withdraw funds from a user's balance.
```json
{
  "amount": 5000
}
```
- **POST** `/api/balance/deposit`
  - Deposit funds into a user's balance.
```json
{
  "amount": 5000
}
```

- **GET** `/api/balance`
  - The logged user's balance is displayed.
