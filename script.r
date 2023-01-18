
library(dplyr)
library(readr)
library(AzureStor)
library(AzureKeyVault)

# connect to kv
print("Connecting to key vault")

keyvault_uri <- "https://{keyvault-name}.vault.azure.net/"
vault <- key_vault(keyvault_uri, as_managed_identity=TRUE)

access_key <- vault$secrets$get("{access-key-name}")$value

# connect to blob
print("Connecting to blob container")

endpoint  <- storage_endpoint("https://{storage-account-name}.blob.core.windows.net",
                   key = access_key)

input_container <- storage_container(endpoint, "input")

input_file_name <- "input_data.csv"
storage_download(input_container, input_file_name, input_file_name, overwrite=T)

df <- read_csv(input_file_name)
head(df)

# upload
print("Uploading output file")

output_file_name <- "output_data.csv"

write_csv(df, output_file_name)

output_container <- storage_container(endpoint, "output")

storage_upload(
  output_container,
  src = output_file_name,
  dest = output_file_name
)
