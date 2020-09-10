# PandaDoc API RubyGem
Ruby Wrapper for PandaDoc API

# Installation 
```ruby 
# Gemfile
gem 'panda_api'
```
```ruby 
# General Install
gem install panda_api
```

# Capabilities 
 
 ## Get Bearer Token
 1. Visit PandaDoc Developers Portal (https://developers.pandadoc.com/)
 2. Visit "My Applications" Tab 
 3. Create PandaDoc Application (Application Name, Application Author, Redirect URI)
 4. Upon completion, you will receive a Client ID and Client Secret
 5. Install panda_api gem and instiate the class 
```ruby 
panda_api_instance = PandaDoc.new(key: "", key_type: "")  
```
 6. Get Code 
 
 ```ruby
 panda_api_instance.get_code({ client_id: <YOUR_CLIENT_ID>, client_secret: <YOUR_CLIENT_SECRET>, redirect_uri: <YOUR_REDIRECT_URI> })
 ```
 7. A browser window will launch. If you are signed into PandaDoc, you authorize PandaDoc 
 8. You will be redirected to your redirect_uri, with your code appended to the URL 
 ```
 https://myredirecturi.com/?state=&code=<YOUR_CODE_TO_PASTE>
 ```
 9. Copy the code. You are prompted to paste the code into your terminal
 10. Your access token will be returned to you
 ```ruby
 {"access_token"=>"<YOUR_ACCESS_TOKEN>",
 "token_type"=>"Bearer",
 "expires_in"=>31535999,
 "scope"=>"read write read+write",
 "refresh_token"=>"<YOUR_REFRESH_TOKEN>”}
 ```
 
 ## Instantiate with API Key
 1. Get API Key from Integrations Page on PandaDoc 
 2. Instantiate new PandaDoc class instance 
 ```ruby
 panda_doc_api_instance = PandaDoc.new(key: <YOUR_API_KEY>, key_type: "api")
 ```
 3. You're Ready to go!
 
 ## Refresh Oauth Token
 ```ruby 
 panda_doc_api_instance = PandaDoc.new(key: <YOUR_BEARER_TOKEN>, key_type: "bearer")
 
 refresh_token = panda_doc_api_instance.refresh_access_token({
  client_id: <YOUR_CLIENT_ID>,
  client_secret: <YOUR_CLIENT_SECRET>,
  # your REFRESH TOKEN, NOT Access Token 
  refresh_token: <YOUR_REFRESH_TOKEN>,
  scope: <read, write, read+write>
 })
 ```
 
 ## Instance Methods 
 (https://developers.pandadoc.com/reference)
 ```ruby 
 panda_doc_api = PandaDoc.new(key: <YOUR_KEY>, key_type: <YOUR_KEY_TYPE>)
 
 # Documents Index (GET)
 panda_doc_api.list_documents({ <YOUR_PARAMS> })
 
 # Templates Index (GET)
 panda_doc_api.list_templates({ <YOUR_PARAMS> })
 
 # Document Details (GET)
 # Document ID Required
 panda_doc_api.document_details({ <YOUR_PARAMS> }) 
 
 # Document Status (GET)
 # Document ID Required
 panda_doc_api.document_status({ <YOUR_PARAMS> }) 
 
 # Template Details (GET)
 # Template ID Required
 panda_doc_api.template_details({ YOUR_PARAMS })
 
 # Create Document (PDF) (POST)
   new_doc = panda_doc_api.create_document_from_pdf(
    # Valid File: File.open(path) || params[:file_uploaded]
    file: file_to_send,
    name: "New PandaDoc Document from PDF",
    recipients: [ { email: "matt@example.com",first_name: "Matt",last_name: "sample",role: "u00"}],
    fields: <YOUR_FIELDS>,
    metadata: <YOUR_META>,
    parse_form_fields: false
  ).body
 
 # Create Document (Template) (POST)
   new_doc = panda_api.create_document_from_template({
    name: "New Doc From Template",
    template_uuid: "<YOUR_TEMPLATE_ID>",
    recipients: [{ first_name: "Balton", last_name: "Reign", email: "client@gmail.com" }],
    tokens: [{ name: "Client.FirstName", value: "Percy" }, { name: "Client.LastName", value: "Johnson" }],
    fields: <YOUR_FIELDS>,
    metadata: <YOUR_META>
  })
  
  # Send Document (POST)
  panda_doc_api.send_document({ id: <YOUR_DOC_ID>, message: <YOUR_MESSAGE>, subject: <YOUR_SUBJECT>, silent: true || false })
  
  # Create Document Session ID (POST)
  panda_doc_api.create_document_link({ id: <YOUR_DOC_ID>, recipient: <YOUR_RECIPIENT_EMAIL>, lifetime: 3600 })
  
  # Download Document (GET)
  panda_doc_api.download_document({ id: <YOUR_DOC_ID> })
  
  # Download Protected Document (GET)
  panda_doc_api.download_protected_document({ id: <YOUR_DOC_ID> })
  
  # Delete Document (DELETE)
  panda_doc_api.delete_document({ id: <YOUR_DOC_ID> })
  
  # Delete Template (DELETE)
  panda_doc_api.delete_document({ id: <YOUR_DOC_ID> })
  
  # Create Document Folder (POST)
  panda_doc_api.create_document_folder({ name: "<YOUR_NEW_FOLDER_NAME>" })
  
  # Create Template Folder (POST)
  panda_doc_api.create_template_folder({ name: "<YOUR_NEW_FOLDER_NAME>" })
  
  # List Template Folders (POST)
  panda_doc_api.list_template_folders({ <YOUR_PARAMS> })
  
  # List Document Folders (POST)
  panda_doc_api.list_document_folders({ <YOUR_PARAMS> })
  
  # Update Document Folder Name (PUT)
  panda_doc_api.update_document_folder({ <YOUR_PARAMS> })
  
  # Update Template Folder Name (PUT)
  panda_doc_api.update_document_folder({ YOUR_PARAMS })
 ```
 
 # Questions / Concerns 
 Please reach out directly to the author, matt.deatherage@pandadoc.com 
