# Import the required libraries for gRPC, including the generated Python classes from the .proto file
import grpc
import crypto_service_pb2 as pb2
import crypto_service_pb2_grpc as pb2_grpc
import concurrent.futures as futures

# Define the GExchangeServicer class that inherits from the pb2_grpc.GExchangeServicer
# This class will handle the gRPC requests for the get_price method
class GExchangeServicer(pb2_grpc.GExchangeServicer):
    # Define the get_price method that takes in a request and context as arguments
    def get_price(self, request, context):
        # Implement the logic to retrieve the market price based on the request.name
        # If the request.name is "Bitcoin", return the market_price message with the specified values
        if request.name == "Bitcoin":
            return pb2.market_price(max_price=50000.0, min_price=48000.0, avg_price=49000.0)
        # If the request.name is "Cardano", return the market_price message with the specified values
        elif request.name == "Cardano":
            return pb2.market_price(max_price=3.3, min_price=2.9, avg_price=3.12)
        # If the request.name is not "Bitcoin" or "Cardano", return the market_price message with 0.0 values
        else:
            return pb2.market_price(max_price=0.0, min_price=0.0, avg_price=0.0)

# Define the serve function that sets up and starts the gRPC server
def serve():
    # Create a new gRPC server with a ThreadPoolExecutor that has a maximum of 10 workers
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    # Add the GExchangeServicer to the server
    pb2_grpc.add_GExchangeServicer_to_server(GExchangeServicer(), server)
    # Add an insecure port to the server on IPv6 localhost and port 50051
    server.add_insecure_port('[::]:50051')
    # Start the server and print a message to the console
    server.start()
    print("running the gRPC server")
    # Wait for the server to terminate
    server.wait_for_termination()

# If the script is being run as the main program, call the serve function to start the gRPC server
if __name__ == "__main__":
    serve()