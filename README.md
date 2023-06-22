# Exbank

## Description

Is a application that connects to other banks and allows you to manage your accounts in one place.
My idea was to create a simple application, only the account credentials are saved tied to the user's client. 
The application does not store any other data, such as account balance, transactions, etc.
It only transform the data from the bank to a standard format and show it to the user.


## How to run

If you have Docker and Docker Compose installed, just run the following command:

```bash
docker-compose up
```

If you have Docker but prefer run the application locally, there is `.tool-versions` file with the Elixir and Erlang versions used in this project.
You can use asdf to install the correct versions. Don't forget to start the Postgres database.

```bash
asdf install
```

After that, you can run the application with:

```bash 
mix start
```

After that, you can vist [`Postman Collection`](https://www.postman.com/restless-capsule-16017/workspace/exbank-api/overview) from your browser to run all the requests. 
All environments variables are configured in the collection. Please, change to your own values if you want to. 

## How to use 

The first step is create the user with a usernmae and password. Only usernames with downcase letters and the underscore character are allowed. Passwords must have at least 6 characters.
Both register and login requests will return a JWT token that must be used in the Authorization header of all other requests. DOnt worry, the Postman collection already does that for you.

After that, you can add the the client data. Every call to the bank API must have the bank name and the client data. The client data is different for each bank.You need to set the bank name, identifier and password. The return of this request is the client id that must be used in all other requests related to this client. You need set the value in the environment variable `client_id` in the Postman collection. 

With the client id, you can get the accounts and transactions. The account request will return all data from the bank account. The transactions request will return all transactions from the bank. Both requests will return the data in a standard format.

## Architecture decisions
###  Exbank

The Bank Providers module acts like a HUB to all bank providers. It is responsible to call the correct bank provider and return the data. There is one Behaviour and two Elixir Protocols to define the contract between the Bank Providers and the Bank Providers module. All new Bank Providers must implement the behaviour and the protocols. These decisions make easy to add new bank providers in the future. 

### Teller Client

Every new client connected to the Exbank application starts a new process via Dynamic Supervisor.
The Teller Client call the Tller Bank API using an module that implements all the requests to the bank API. The Teller Bank API module is responsible to call the correct bank API and return the data. 
My main idea was to create a separate connection to each client, storing the authentication logic anda data. If one user is compromised, the others are not affected.


## Disclaimers

This application is just a proof of concept. It is not production ready.
The application does not store any data, it only transform the data from the bank to a standard format and show it to the user.
The application does not have a strong security layer, despite all password are being encrypted on the database.
The application does not have a strong error handling, remember: it is just a proof of concept.