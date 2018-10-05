#  SocialDeck GraphQL API Schema

## Queries

List of block users:

```graphql
{
  blockedUsers(token:String!) {
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
  contacts(token:String!) {
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
  logs(token:String!, cardId:ID!) {
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
  card(token:String!, id:ID!) {
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
  authoredCards(token:String!) {
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
  ownedCards(token:String!) {
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
  login(user: {username:String!, password:String!}!) {
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

Create an new user. Will validate email and number.

```graphql
mutation {
  createUser(user: {username:String!, password:String!}!, 
             email:String!, number:String!) {
    id
    username
    email
    number
  }
}
```

Create a new card. If an orphaned card, will automatically create a connection as well. Will validate email and number.
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
  createConnection(token:String!,  cardId:ID!) {
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
  blockUser(token:String!,  userId:ID!) {
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

Update User
```
mutation {
  updateUser(token: String!, username: String!){
    username
  }
}
```

Update Card
```
mutation {
  updateCard(token:String!, id: 3, cardName: String!, displayName:String!, name:String!, 
             number:String!,address: {city: String}, twitter:String, facebook:String, linkedIn:String, 
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

Update Connection
```
mutation {
  updateConnection(token:String!, id:ID!, cardId:ID!) {
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

Destroy User
```
mutation {
  destroyUser(token:String!){
    message
  }
}
```

Destroy Card
```
mutation {
  destroyCard(token:String!, id:ID!){
    message
  }
}
```

Destroy Connection
```
mutation {
  destroyConnection(token: String!, id: ID!){
    message
  }
}
```