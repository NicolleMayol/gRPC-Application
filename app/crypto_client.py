import grpc                                 # Import the gRPC library for making remote procedure calls
import crypto_service_pb2 as pb2            # Import the generated message classes for the crypto service
import crypto_service_pb2_grpc as pb2_grpc  # Import the generated gRPC stubs for the crypto service
import os
class FetchPrices:
    """A class for fetching cryptocurrency prices from a gRPC server."""

    def __init__(self):
        """Initialize a new instance of the FetchPrices class.

        Establish an insecure connection to the gRPC server running on localhost at port 50051,
        and create a new gRPC stub for the GExchange service.
        """
        server_address = os.getenv('SERVER_ADDRESS', 'localhost:50051')
        self.channel = grpc.insecure_channel(server_address)
        self.stub = pb2_grpc.GExchangeStub(self.channel)

    def get_price(self, name):
        """Fetch the price of a cryptocurrency with the given name.

        Args:
            name (str): The name of the cryptocurrency.

        Returns:
            pb2.Price: The price of the cryptocurrency.
        """
        request = pb2.cryptocurrency(name=name)
        response = self.stub.get_price(request)
        return response

if __name__ == "__main__":
    """Run the main program."""
    client = FetchPrices()
    print(client.get_price("Bitcoin"))
    print(client.get_price("Cardano"))