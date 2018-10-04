#  SocialDeck GraphQL API Schema

## Queries

List of block users:

```graphql
{
  blockedUsers(token: "qAnCqd1dBZDEBrZcb2fH7a3n") {
    id
    username
    email
    number
  }
}
```
List of all contacts:

```graphql
{
  contacts(token: "qAnCqd1dBZDEBrZcb2fH7a3n") {
    id
    user {
      id
      username
      email
      number
    }
    author {
      id
      username
      email
      number
    }
    name
    displayName
    personName
    businessName
    address {
      address1
      address2
      city
      state
      postalCode
    }
    number
    email
    birthDate
    twitter
    linkedIn
    facebook
    instagram
    verified
  }
}
```


List of all users

```graphql
{
  users {
    id
    username
    email
    number
  }
}
```

List of all logs associated with a card

```graphql
{
  logs(token: "qAnCqd1dBZDEBrZcb2fH7a3n", cardId: 42) {
    id
    user {
      id
      username
      email
      number
    }
    contact {
      id
      username
      email
      number
    }
    card {
      id
      user {
        id
        username
        email
        number
      }
      author {
        id
        username
        email
        number
      }
      name
      displayName
      personName
      businessName
      address {
        address1
        address2
        city
        state
        postalCode
      }
      number
      email
      birthDate
      twitter
      linkedIn
      facebook
      instagram
      verified
    }
    date
    text
  }
}
```

Get a specific card that is owned, authored, or connected

```graphql
{
  card(token: "qAnCqd1dBZDEBrZcb2fH7a3n", id: 42) {
    id
    user {
      id
      username
      email
      number
    }
    author {
      id
      username
      email
      number
    }
    name
    displayName
    personName
    businessName
    address {
      address1
      address2
      city
      state
      postalCode
    }
    number
    email
    birthDate
    twitter
    linkedIn
    facebook
    instagram
    verified
  }
}
```
List of all orphan cards authored 
```graphql
{
  authoredCards(token: "qAnCqd1dBZDEBrZcb2fH7a3n") {
    id
    user {
      id
      username
      email
      number
    }
    author {
      id
      username
      email
      number
    }
    name
    displayName
    personName
    businessName
    address {
      address1
      address2
      city
      state
      postalCode
    }
    number
    email
    birthDate
    twitter
    linkedIn
    facebook
    instagram
    verified
  }
}
```
List of one's own cards
```graphql
{
  ownedCards(token: "qAnCqd1dBZDEBrZcb2fH7a3n") {
    id
    user {
      id
      username
      email
      number
    }
    author {
      id
      username
      email
      number
    }
    name
    displayName
    personName
    businessName
    address {
      address1
      address2
      city
      state
      postalCode
    }
    number
    email
    birthDate
    twitter
    linkedIn
    facebook
    instagram
    verified
  }
}
```

## Mutations


Log in
```graphql
mutation {
  login(user: {username: "douglas.adams", password: "42"}) {
    user {
      id
      username
      email
      number
    }
    token
  }
}
```
Create an new user

```graphql
mutation {
  createUser(user: {username: "douglas.adams", password: "42"}, 
             email: "arthur@dent.com", number:"5555555555") {
    id
    username
    email
    number
  }
}
```
Create a new card
```graphql
mutation {
  createCard(token:String!, owned:Boolean!, cardName:String!, displayName:String, name:String!, 
             number:String, email:String, address: {address1:String!, address2:String, city: String!, 
             state:String!, postalCode:String!}, twitter:String, facebook:String, linkedIn:String, 
             instagram:String) {
    id
    user {
      id
      username
      email
      number
    }
    author {
      id
      username
      email
      number
    }
    name
    displayName
    personName
    businessName
    address {
      address1
      address2
      city
      state
      postalCode
    }
    number
    email
    birthDate
    twitter
    linkedIn
    facebook
    instagram
    verified
  }
}

```
Create a connection
```graphql
mutation {
  createConnection(token: "ab58KfZnAN7HfizVAJUHgGsH",  cardId:45) {
id
    user {
      id
      username
      email
      number
    }
    contact {
      id
      username
      email
      number
    }
    card {
      id
      user {
        id
        username
        email
        number
      }
      author {
        id
        username
        email
        number
      }
      name
      displayName
      personName
      businessName
      address {
        address1
        address2
        city
        state
        postalCode
      }
      number
      email
      birthDate
      twitter
      linkedIn
      facebook
      instagram
      verified
    }
  }
}
```
Block User
```graphql
mutation {
  createConnection(token: "ab58KfZnAN7HfizVAJUHgGsH",  userId:45) {
id
    user {
      id
      username
      email
      number
    }
    contact {
      id
      username
      email
      number
    }
    card {
      id
    }
  }
}
```