# Cute Bank

## API Endpoints

### Health Check

- **GET** `/api/health_check`
  - Endpoint for checking the health status of the system.

### User Management

- **POST** `/api/user/create`
  - Create a new user account.
  ```json
  {
    "cpf": "000.000.000-00",
    "password": "s3cure_pa$sword"
  }
  ```
- **POST** `/api/user/login`
  - Log in an existing user.
  ```json
  {
    "user": {
      "first_name": "John",
      "last_name": "Doe",
      "cpf": "000.000.000-00",
      "password": "s3cure_pa$sword",
    }
  }
  ```

### Transaction Management

- **POST** `/api/transaction/create`
  - Create a new transaction.
  ```json
  {
    "transaction": {
      "amount": 5000,
      "receiver_pdf": "000.000.000-00",
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

## Authentication

Authentication is required for some of the endpoints. Make sure to include appropriate authentication tokens in your requests when accessing protected routes.

## Getting Started

1. **Installation**
   - Clone the repository and install the required dependencies.

2. **Build Containers**
   - Set up your database configuration and any environment-specific settings.
```bash
$ docker-compose up -d
```

3. **Database Migration**
   - Run database migrations to create the necessary tables.
```bash
$ mix ecto.create
$ mix ecto.migrate
```

4. **Running the Application**
   - Start the application and ensure it's accessible.
```bash
$ mix phx.server
```

## Additional Documentation

For more detailed information about the system, additional configuration options, and API request/response examples, refer to the official documentation [link-to-documentation].

## Contribute

We welcome contributions to enhance and improve this Transaction System. Feel free to submit pull requests or report any issues in the repository.

## License

This project is licensed under the [License Name] - see the [LICENSE.md](LICENSE.md) file for details.
